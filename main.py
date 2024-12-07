from fastapi import FastAPI, HTTPException, Query, status
from pydantic import BaseModel
import psycopg
from psycopg import sql
import os
from dotenv import load_dotenv

# Carrega as variaveis de ambiente
load_dotenv()

# Configurações do banco de dados a partir das variaveis de ambiente
DATABASE_URL = f"postgresql://{os.getenv('POSTGRES_USER')}:{os.getenv('POSTGRES_PASSWORD')}@{os.getenv('POSTGRES_HOST')}:{os.getenv('POSTGRES_PORT')}/{os.getenv('POSTGRES_DB')}"

app = FastAPI()

# Conectar ao banco de dados
def get_db_connection():
    conn = psycopg.connect(DATABASE_URL)
    return conn

# Model para dados do pedido
class PedidoBase(BaseModel):
    Usuario_CPF: str
    Espaco_Id: int
    Administrador_CPF: str = None  # Administrador_CPF pode ser nulo
    Status: str = 'E'  # Padrão: "E" para em espera

class PedidoResponse(PedidoBase):
    Codigo: int  # Retorna o código do pedido ao inserir
    class Config:
        orm_mode = True

@app.get("/check_usuario")
async def check_user(cpf: str = Query(..., min_length=11, max_length=11)):
    """
    Verifica se o usuário existe na tabela Comum baseado no CPF informado.
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Consulta parametrizada para evitar SQL Injection
        query = sql.SQL("SELECT Usuario_CPF FROM Comum WHERE Usuario_CPF = %s")
        cursor.execute(query, (cpf,))

        result = cursor.fetchone()

        cursor.close()
        conn.close()

        if result:
            return {"data": cpf}
        else:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Usuario nao encontrado")

    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


@app.get("/check_partida")
async def get_upcoming_public_matches(
    cpf: str = Query(..., min_length=11, max_length=11)
):
    """
    Retorna as partidas públicas futuras junto com informações sobre o espaço e a instalação,
    excluindo as partidas em que o usuário já está participando.
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Consulta parametrizada para evitar SQL Injection
        query = sql.SQL("""
            SELECT 
                p.Data_Hora_Inicio, 
                p.Esporte, 
                e.Nome AS Nome_Espaco, 
                i.Nome AS Nome_Instalacao
            FROM Partida p
            JOIN Aberto a ON a.Partida_Id = p.Id
            JOIN Espaco e ON p.Espaco_Id = e.Id
            JOIN Instalacao i ON e.Rua = i.Rua 
                AND e.Nro_rua = i.Nro_rua 
                AND e.Cidade = i.Cidade 
                AND e.Estado = i.Estado 
                AND e.CEP = i.CEP
            LEFT JOIN Participa part ON part.Aberto_Id = p.Id AND part.Comum_CPF = %s
            WHERE p.Data_Hora_Inicio >= CURRENT_TIMESTAMP
                AND p.Comum_CPF != %s
                AND part.Comum_CPF IS NULL
            ORDER BY p.Data_Hora_Inicio;
        """)

        cursor.execute(query, (cpf,cpf,))
        result = cursor.fetchall()

        # Estruturar os resultados
        response = [
            {
                "data_hora_inicio": row[0],
                "esporte": row[1],
                "nome_espaco": row[2],
                "nome_instalacao": row[3]
            }
            for row in result
        ]

        cursor.close()
        conn.close()

        return {"data": response}

    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


@app.post("/add_pedido")
async def criar_e_listar_pedidos(pedido: PedidoBase):
    """
    Cria um novo pedido e lista todos os pedidos do usuário baseado no CPF fornecido.
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Insere o novo pedido
        query_insert = sql.SQL("""
            INSERT INTO Pedido (Usuario_CPF, Espaco_Id, Administrador_CPF, Status)
            VALUES (%s, %s, %s, %s)
            RETURNING Codigo;
        """)
        
        cursor.execute(query_insert, (pedido.Usuario_CPF, pedido.Espaco_Id, pedido.Administrador_CPF, pedido.Status))
        codigo = cursor.fetchone()[0]

        # Agora, lista todos os pedidos do usuário baseado no CPF fornecido
        query_select = sql.SQL("""
            SELECT Codigo, Usuario_CPF, Espaco_Id, Administrador_CPF, Status
            FROM Pedido
            WHERE Usuario_CPF = %s
            ORDER BY Codigo DESC;
        """)
        
        cursor.execute(query_select, (pedido.Usuario_CPF,))
        result = cursor.fetchall()

        pedidos = [
            {
                "Codigo": row[0],
                "Usuario_CPF": row[1],
                "Espaco_Id": row[2],
                "Administrador_CPF": row[3],
                "Status": row[4]
            }
            for row in result
        ]

        conn.commit()

        cursor.close()
        conn.close()

        # Retorna o código do pedido recém-criado e a lista dos pedidos do usuário
        return {
            "data": pedidos
        }

    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
