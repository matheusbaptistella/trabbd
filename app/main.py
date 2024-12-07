import requests

BASE_URL = "http://127.0.0.1:8000"

def clear_screen():
    """Limpa a tela do terminal"""
    print("\033[H\033[J", end="")


def print_table(data, headers):
    """Exibe os dados em formato de tabela"""
    if not data:
        print("Sem dados para mostrar.")
        return
    
    print(f"{' | '.join(headers)}")
    print("-" * 40)
    
    for row in data:
        row_values = [str(row.get(header, 'N/A')) for header in headers]
        print(f"{' | '.join(row_values)}")
    
    print("-" * 40)


def login():
    """Função de login para verificar o CPF"""
    while True:
        cpf = input("Digite seu CPF (11 dígitos): ").strip()
        if len(cpf) != 11 or not cpf.isdigit():
            print("CPF inválido. Tente novamente.")
            continue
        
        try:
            response = requests.get(f"{BASE_URL}/check_usuario?cpf={cpf}")
            if response.status_code == 200:
                print(f"Usuário {cpf} logado com sucesso!")
                return cpf
            elif response.status_code == 404:
                print("Usuário não encontrado. Verifique o CPF e tente novamente.")
            else:
                print("Erro ao verificar o usuário. Tente novamente mais tarde.")
        except requests.exceptions.RequestException as e:
            print(f"Erro de conexão: {e}")
        break 

    return None


def menu_logged_in(cpf):
    """Exibe o menu após o login"""
    while True:
        clear_screen()
        print(f"Usuário logado: {cpf}")
        print("[1] Buscar partidas futuras")
        print("[2] Fazer um pedido")
        print("[3] Sair")
        
        choice = input("Escolha uma opção: ").strip()
        
        if choice == "1":
            search_partida(cpf)
        elif choice == "2":
            add_pedido(cpf)
        elif choice == "3":
            print("Saindo...")
            break
        else:
            print("Opção inválida. Tente novamente.")


def search_partida(cpf):
    """Chama a API para buscar partidas futuras"""
    print("Buscando partidas futuras...")
    try:
        response = requests.get(f"{BASE_URL}/check_partida?cpf={cpf}")
        if response.status_code == 200:
            data = response.json().get("data", [])
            if data:
                headers = ["data_hora_inicio", "esporte", "nome_espaco", "nome_instalacao"]
                print_table(data, headers)
            else:
                print("Nenhuma partida futura encontrada.")
        else:
            print(f"Erro ao buscar partidas: {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Erro de conexão: {e}")
    input("Pressione Enter para voltar ao menu.")


def add_pedido(cpf):
    """Chama a API para adicionar um pedido"""
    while True:
        try:
            espaco_id = int(input("Digite o ID do espaço onde deseja fazer o pedido: ").strip())
            status = "E"
            data = {
                "Usuario_CPF": cpf,
                "Espaco_Id": espaco_id,
                "Status": status
            }
            
            response = requests.post(f"{BASE_URL}/add_pedido", json=data)
            
            if response.status_code == 200:
                result = response.json()
                
                pedidos = result.get("data", [])
                
                if pedidos:
                    headers = ["Codigo", "Usuario_CPF", "Espaco_Id", "Administrador_CPF", "Status"]
                    print_table(pedidos, headers)
                else:
                    print("Nenhum pedido encontrado ou retornado para o usuário.")
            else:
                print(f"Erro ao adicionar pedido: {response.text}")
                break

        except ValueError:
            print("ID do espaço inválido.")
            break
        except requests.exceptions.RequestException as e:
            print(f"Erro de conexão: {e}")
            break
        input("Pressione Enter para tentar novamente.")


def main():
    """Menu principal da aplicação em linha de comando"""
    clear_screen()
    while True:
        print("[1] Logar")
        print("[2] Sair")
        
        choice = input("Escolha uma opção: ").strip()
        
        if choice == "1":
            cpf = login()
            if cpf: 
                menu_logged_in(cpf)
            else:
                print("Login falhou. Tentando novamente...")
        elif choice == "2":
            print("Saindo...")
            break
        else:
            print("Opção inválida. Tente novamente.")

if __name__ == "__main__":
    main()
