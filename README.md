# Parte 3 - Grupo 6
Para executar a aplicação é preciso ter o Python 3 e o Docker instalados na máquina. Uma vez dentro da raíz do projeto, deve-se inicializar as instâncias dos serviços da api e do banco de dados por meio do comando:
```
docker compose up --build
```
E em seguida entrar no diretório da aplicação:
```
cd ./app 
```
Por fim, basta executar a aplicação localmente:
```
python3 main.py
```
E então interagir com a interface. Para melhor utilizaçào, é válido observar quais CPFs e IDs de Espaços já foram caddastrados no sistema no arquivo `./sql/insercao.sql` (para CPF é válido utilizar por exemplo `98765432100` e para espaço o id `1`).