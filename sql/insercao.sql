-- Insercao nas tabelas do banco de dados PostgreSQL

-- Inserir dados na tabela Usuario
INSERT INTO Usuario (CPF, Nome) VALUES 
('12345678901', 'Rafael'), 
('98765432100', 'Maria'),
('11223344556', 'Carlos'),
('11111111111', 'Leonardo'), 
('22222222222', 'Gabriela'),
('33333333333', 'Marina');


-- Inserir dados na tabela Comum
INSERT INTO Comum (Usuario_CPF, Data_Nasc, Genero) VALUES 
('12345678901', '1995-03-15', 'M'),
('98765432100', '2000-08-22', 'F'),
('11223344556', '1998-12-30', 'O');


-- Inserir dados na tabela Administrador
INSERT INTO Administrador (Usuario_CPF, Cidade, Nro_Funcional) VALUES 
('11111111111', 'Americana', 1001),
('22222222222', 'Piracicaba', 1002),
('33333333333', 'Campinas', 1003);


-- Inserir dados na taela Instalacao
INSERT INTO Instalacao (Rua, Nro_rua, Cidade, Estado, CEP, Nome, Administrador_CPF) VALUES 
('Rua A', 123, 'Americana', 'SP', '01001000', 'Instalação Azul', '11111111111'),
('Rua B', 456, 'Piracicaba', 'SP', '20020000', 'Instalação Laranja', '22222222222'),
('Rua C', 789, 'Campinas', 'SP', '30130000', 'Instalação Verde', '33333333333');


-- Inserir dados na tabela Espaco
INSERT INTO Espaco (Rua, Nro_rua, Cidade, Estado, CEP, Nome) VALUES 
('Rua A', 123, 'Americana', 'SP', '01001000', 'Espaco Azul-123'),
('Rua A', 123, 'Americana', 'SP', '01001000', 'Espaco Azul-456'),
('Rua A', 123, 'Americana', 'SP', '01001000', 'Espaco Azul-789'),
('Rua B', 456, 'Piracicaba', 'SP', '20020000', 'Espaco Laranja-123'),
('Rua C', 789, 'Campinas', 'SP', '30130000', 'Espaco Verde-123'),
('Rua C', 789, 'Campinas', 'SP', '30130000', 'Espaco Verde-456');


-- Inserir dados na tabela Equipamento
INSERT INTO Equipamento (Tipo) VALUES 
('Rede de Volei'),
('Bola de Futebol'),
('Bola de Basquete');


-- Inserir dados na tabela MaterialEsportivo
INSERT INTO MaterialEsportivo (Espaco_Id, Equipamento_Id, Quantidade) VALUES 
(1, 1, 3),
(1, 2, 7),
(1, 3, 2),
(2, 2, 5),
(3, 3, 8),
(4, 1, 1),
(5, 2, 10),
(6, 3, 4);


-- Inserir dados na tabela Pedido
INSERT INTO Pedido (Usuario_CPF, Espaco_Id, Administrador_CPF, Status) VALUES 
('12345678901', 1, '11111111111', 'A'),
('12345678901', 1, '11111111111', 'A'),
('12345678901', 2, '11111111111', 'R'),
('98765432100', 1, '11111111111', 'A'),
('11223344556', 3, '11111111111', 'A'),
('98765432100', 4, '22222222222', 'A'),
('11223344556', 6, '33333333333', 'R');


-- Inserir dados na tabela Manutencao
INSERT INTO Manutencao (Data_Hora_Inicio, Data_Hora_Fim, Espaco_Id, Comum_CPF, Pedido_Codigo, Descricao) VALUES 
('2024-12-01 10:00:00', '2024-12-01 12:00:00', 1, '12345678901', 1, 'Manutenção preventiva'),
('2024-12-02 14:00:00', '2024-12-02 16:00:00', 1, '12345678901', 2, 'Troca de lâmpadas'),
('2024-12-03 09:00:00', '2024-12-03 10:00:00', 1, '98765432100', 4, 'Limpeza do espaço'),
('2024-12-04 11:00:00', '2024-12-04 12:00:00', 3, '11223344556', 5, 'Inspeção da estrutura'),
('2024-12-05 19:00:00', '2024-12-05 20:00:00', 4, '98765432100', 6, 'Acabamento do piso');


-- Inserir dados na tabela Campeonato
INSERT INTO Campeonato (Administrador_CPF, Espaco_Id, Data_Hora_Inicio, Data_Hora_Fim) VALUES 
('11111111111', 1, '2024-12-10 08:00:00', '2024-12-20 12:00:00'),
('22222222222', 4, '2024-12-15 09:00:00', '2024-12-16 13:00:00'),
('33333333333', 6, '2024-12-18 14:00:00', '2024-12-25 18:00:00');


-- Inserir dados na tabela InscricaoCamp
INSERT INTO InscricaoCamp (Comum_CPF, Administrador_CPF, Espaco_Id, Data_Hora_Inicio) VALUES 
('12345678901', '11111111111', 1, '2024-12-10 08:00:00'),
('98765432100', '11111111111', 1, '2024-12-10 08:00:00'),
('98765432100', '22222222222', 4, '2024-12-15 09:00:00'),
('11223344556', '33333333333', 6, '2024-12-18 14:00:00');


-- Inserir dados na tabela Partida
INSERT INTO Partida (Data_Hora_Inicio, Comum_CPF, Espaco_Id, Data_Hora_Fim, Publico, Esporte) VALUES 
('2024-12-10 08:00:00', '12345678901', 1, '2024-12-10 10:00:00', 'F', 'Volei'),
('2024-12-11 14:00:00', '98765432100', 1, '2024-12-11 15:00:00', 'F', 'Volei'),
('2024-12-11 16:00:00', '98765432100', 2, '2024-12-11 17:00:00', 'A', 'Futebol'),
('2024-12-11 20:00:00', '12345678901', 3, '2024-12-11 21:00:00', 'A', 'Basquete'),
('2024-12-12 14:00:00', '98765432100', 5, '2024-12-12 16:00:00', 'A', 'Futebol'),
('2024-12-17 14:00:00', '12345678901', 4, '2024-12-17 16:00:00', 'A', 'Volei'),
('2024-12-26 18:00:00', '11223344556', 6, '2024-12-26 20:00:00', 'A', 'Basquete');


-- Inserir dados na tabela Aberto
INSERT INTO Aberto (Partida_Id) VALUES 
(3),
(4),
(5),
(6),
(7);


-- Inserir dados na tabela Fechado
INSERT INTO Fechado (Partida_Id) VALUES 
(1),
(2);


-- Inserir dados na tabela Participa
INSERT INTO Participa (Comum_CPF, Aberto_Id, Time_Comum) VALUES 
('12345678901', 3, 'Time A'),
('98765432100', 4, 'Time Azul'),
('98765432100', 6, 'Time Casa');


-- Inserir dados na tabela PartidaCamp
INSERT INTO PartidaCamp (Fechado_Id, Administrador_CPF, Espaco_Id, Data_Hora_Inicio) VALUES 
(1, '11111111111', 1, '2024-12-10 08:00:00'),
(2, '11111111111', 1, '2024-12-10 08:00:00');


-- Inserir dados na tabela PartidaUtilizaMaterial
INSERT INTO PartidaUtilizaMaterial (Partida_Id, Espaco_Id, Equipamento_Id) VALUES 
(1, 1, 1),
(2, 1, 1),
(3, 2, 2),
(4, 3, 3),
(5, 5, 2),
(6, 4, 1),
(7, 6, 3);
