-- Consultas SQL para o banco de dados Postgres

-- Listar os jogadores e os times das partidas abertas que o jogador participa
SELECT 
    u.Nome AS Usuario, 
    pt.Time_Comum AS Time,
    p.Data_Hora_Inicio AS Partida_Inicio, 
    p.Data_Hora_Fim AS Partida_Fim, 
    p.Esporte AS Esporte
FROM Comum c
JOIN Usuario u ON u.CPF = c.Usuario_CPF 
JOIN Participa pt ON c.Usuario_CPF = pt.Comum_CPF 
JOIN Aberto a ON pt.Aberto_Id = a.Partida_Id 
JOIN Partida p ON a.Partida_Id = p.Id 
WHERE c.Usuario_CPF = '12345678901' 
    AND p.Publico = 'A' 
ORDER BY p.Data_Hora_Inicio; 


-- Listar as partidas abertas disponiveis para o usuario participar a partir do momento de busca (exclui as que ele mesmo organizou, que estao fechados ou que ja esta participando)
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
LEFT JOIN Participa part ON part.Aberto_Id = p.Id AND part.Comum_CPF = '12345678901'
WHERE p.Data_Hora_Inicio >= CURRENT_TIMESTAMP
    AND p.Comum_CPF != '12345678901'
    AND part.Comum_CPF IS NULL
ORDER BY p.Data_Hora_Inicio;


-- Listar os administradores que aprovaram mais de 3 pedidos de manutencao
SELECT 
    u.Nome AS Nome_Administrador, 
    ad.Cidade, 
    COUNT(p.Codigo) AS Pedidos_Aprovados
FROM Pedido p
JOIN Administrador ad ON p.Administrador_CPF = ad.Usuario_CPF
JOIN Usuario u ON ad.Usuario_CPF = u.CPF
WHERE p.Status = 'A'
GROUP BY u.Nome, ad.Cidade
HAVING COUNT(p.Codigo) > 3;


-- Listar campeonatos que ainda nao comecaram e identificar em quais o usuario ja esta insscrito
SELECT 
    c.Administrador_CPF, 
    c.Espaco_Id, 
    c.Data_Hora_Inicio, 
    c.Data_Hora_Fim, 
    c.Vencedor, 
    CASE 
        WHEN i.Comum_CPF IS NOT NULL THEN 'INSCRITO'
        ELSE 'NAO INSCRITO'
    END AS Status_Inscricao
FROM Campeonato c
LEFT JOIN InscricaoCamp i ON c.Espaco_Id = i.Espaco_Id 
    AND c.Data_Hora_Inicio = i.Data_Hora_Inicio
    AND i.Comum_CPF = '12345678901'
WHERE c.Data_Hora_Inicio >= CURRENT_TIMESTAMP;


-- Divisão relacional para encontrar os Espaços que possuem todos os materiais disponiveis no sistema (quadra poli esportivas)
SELECT e.Id AS Espaco_Id, e.Nome AS Nome_Espaco
FROM Espaco e
WHERE NOT EXISTS (
    SELECT eq.Id 
    FROM Equipamento eq
    WHERE NOT EXISTS (
        SELECT me.Espaco_Id
        FROM MaterialEsportivo me
        WHERE me.Espaco_Id = e.Id
            AND me.Equipamento_Id = eq.Id
            AND me.Quantidade > 0
    )
);
