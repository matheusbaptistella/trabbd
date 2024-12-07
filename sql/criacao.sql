-- Criacao das tabelas do banco de dados PostgreSQL

-- Tabela Usuario
CREATE TABLE Usuario (
    CPF CHAR(11) NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    CONSTRAINT pk_usuario PRIMARY KEY (CPF),
    CONSTRAINT chk_cpf CHECK (CPF ~ '^\d{11}$')
);


-- Tabela Comum (Usuário comum)
CREATE TABLE Comum (
    Usuario_CPF CHAR(11) NOT NULL,
    Data_Nasc DATE NOT NULL,
    Genero CHAR(1) NOT NULL,
    CONSTRAINT pk_comum PRIMARY KEY (Usuario_CPF),
    CONSTRAINT fk_comum FOREIGN KEY (Usuario_CPF) REFERENCES Usuario(CPF) ON DELETE CASCADE,
    CONSTRAINT chk_data_nasc CHECK (Data_Nasc <= CURRENT_DATE AND AGE(Data_Nasc) >= INTERVAL '18 years'),
    CONSTRAINT chk_genero CHECK (Genero IN('M', 'F', 'O'))
);


-- Tabela Administrador
CREATE TABLE Administrador (
    Usuario_CPF CHAR(11) NOT NULL,
    Cidade VARCHAR(50) NOT NULL,
    Nro_Funcional INT NOT NULL,
    CONSTRAINT pk_administrador PRIMARY KEY (Usuario_CPF),
    CONSTRAINT fk_administrador FOREIGN KEY (Usuario_CPF) REFERENCES Usuario(CPF) ON DELETE CASCADE,
    CONSTRAINT sk_administrador UNIQUE (Nro_Funcional)
);


-- Tabela Instalação
CREATE TABLE Instalacao (
    Rua VARCHAR(50) NOT NULL,
    Nro_rua INT NOT NULL,
    Cidade VARCHAR(50) NOT NULL,
    Estado CHAR(2) NOT NULL,
    CEP  CHAR(8) NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    Hor_Abre TIME NOT NULL DEFAULT '08:00:00',
    Hor_Fecha TIME NOT NULL DEFAULT '22:00:00',
    Administrador_CPF CHAR(11),
    CONSTRAINT pk_instalacao PRIMARY KEY (Rua, Nro_rua, Cidade, Estado, CEP),
    CONSTRAINT fk_instalacao FOREIGN KEY (Administrador_CPF) REFERENCES Administrador(Usuario_CPF) ON DELETE SET NULL, -- Se um adm for removido, deve-se atribuir um novo adm futuramente
    CONSTRAINT chk_cep CHECK (CEP ~ '^\d{8}$')
);


-- Tabela Espaço
CREATE TABLE Espaco (
    Id SERIAL NOT NULL,
    Rua VARCHAR(50) NOT NULL,
    Nro_rua INT NOT NULL,
    Cidade VARCHAR(50) NOT NULL,
    Estado CHAR(2) NOT NULL,
    CEP  CHAR(8) NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    CONSTRAINT pk_espaco PRIMARY KEY (Id),
    CONSTRAINT fk_espaco FOREIGN KEY (Rua, Nro_rua, Cidade, Estado, CEP) REFERENCES Instalacao(Rua, Nro_rua, Cidade, Estado, CEP) ON DELETE CASCADE, -- Se uma instalcao eh removida, o seus espacos devem ser tambem.
    CONSTRAINT sk_espaco UNIQUE (Rua, Nro_rua, Cidade, Estado, CEP, Nome)
);


-- Tabela Equipamento
CREATE TABLE Equipamento (
    Id SERIAL NOT NULL,
    Tipo VARCHAR(50) NOT NULL,
    CONSTRAINT pk_equipamento PRIMARY KEY (Id),
    CONSTRAINT sk_equipamento UNIQUE (Tipo)
);


-- Tabela Material Esportivo
CREATE TABLE MaterialEsportivo (
    Espaco_Id INT NOT NULL,
    Equipamento_Id INT NOT NULL,
    Quantidade INT NOT NULL,
    CONSTRAINT pk_material_esportivo PRIMARY KEY (Espaco_Id, Equipamento_Id),
    CONSTRAINT fk1_material_esportivo FOREIGN KEY (Espaco_Id) REFERENCES Espaco(Id) ON DELETE CASCADE, -- Caso o espaco ou o material sejam removidos, deve-se remover a relacao aqui tbm
    CONSTRAINT fk2_material_esportivo FOREIGN KEY (Equipamento_Id) REFERENCES Equipamento(Id) ON DELETE CASCADE,
    CONSTRAINT chk_qtd_positiva_material_esportivo CHECK (Quantidade >= 0)
);


-- Tabela Pedido
CREATE TABLE Pedido (
    Codigo SERIAL,
    Usuario_CPF CHAR(11) NOT NULL,
    Espaco_Id INT NOT NULL,
    Administrador_CPF CHAR(11),
    Status CHAR(1) NOT NULL DEFAULT 'E',
    CONSTRAINT pk_pedido PRIMARY KEY (Codigo),
    CONSTRAINT fk1_pedido FOREIGN KEY (Usuario_CPF) REFERENCES Usuario(CPF),
    CONSTRAINT fk2_pedido FOREIGN KEY (Espaco_Id) REFERENCES Espaco(Id) ON DELETE CASCADE, -- Caso o espaco seja deletado nao faz sentido manter um pedido para ele
    CONSTRAINT fk3_pedido FOREIGN KEY (Administrador_CPF) REFERENCES Administrador(Usuario_CPF),
    CONSTRAINT chk_adm_status_pedido CHECK (Status IN ('E') OR (Status IN ('A', 'R') AND Administrador_CPF IS NOT NULL))
);


-- Tabela Manutenção
CREATE TABLE Manutencao (
    Data_Hora_Inicio TIMESTAMP NOT NULL,
    Data_Hora_Fim TIMESTAMP NOT NULL,
    Espaco_Id INT NOT NULL,
    Comum_CPF CHAR(11) NOT NULL,
    Pedido_Codigo INT NOT NULL,
    Descricao VARCHAR(255) NOT NULL,
    CONSTRAINT pk_manutencao PRIMARY KEY (Data_Hora_Inicio, Espaco_Id, Comum_CPF),
    CONSTRAINT fk1_manutencao FOREIGN KEY (Espaco_Id) REFERENCES Espaco(Id) ON DELETE CASCADE, -- Caso o espaco seja deletado nao faz sentido manter uma manutencao feita nele
    CONSTRAINT fk2_manutencao FOREIGN KEY (Comum_CPF) REFERENCES Comum(Usuario_CPF),
    CONSTRAINT fk3_manutencao FOREIGN KEY (Pedido_Codigo) REFERENCES Pedido(Codigo),
    CONSTRAINT sk_manutencao UNIQUE (Pedido_Codigo),
    CONSTRAINT chk_data_hora_fim_manutencao CHECK (Data_Hora_Fim > Data_Hora_Inicio)
);


-- Tabela Campeonato
CREATE TABLE Campeonato (
    Administrador_CPF CHAR(11) NOT NULL,
    Espaco_Id INT NOT NULL,
    Data_Hora_Inicio TIMESTAMP NOT NULL,
    Data_Hora_Fim TIMESTAMP NOT NULL,
    Vencedor VARCHAR(100),
    CONSTRAINT pk_campeonato PRIMARY KEY (Administrador_CPF, Espaco_Id, Data_Hora_Inicio),
    CONSTRAINT fk1_campeonato FOREIGN KEY (Administrador_CPF) REFERENCES Administrador(Usuario_CPF),
    CONSTRAINT fk2_campeonato FOREIGN KEY (Espaco_Id) REFERENCES Espaco(Id) ON DELETE CASCADE,
    CONSTRAINT chk_data_hora_fim_campeonato CHECK (Data_Hora_Fim > Data_Hora_Inicio)
);


-- Tabela Inscrição de Campeonato
CREATE TABLE InscricaoCamp (
    Comum_CPF CHAR(11) NOT NULL,
    Administrador_CPF CHAR(11) NOT NULL,
    Espaco_Id INT NOT NULL,
    Data_Hora_Inicio TIMESTAMP NOT NULL,
    CONSTRAINT pk_inscricao_camp PRIMARY KEY (Comum_CPF, Administrador_CPF, Espaco_Id, Data_Hora_Inicio),
    CONSTRAINT fk1_inscricao_camp FOREIGN KEY (Comum_CPF) REFERENCES Comum(Usuario_CPF),
    CONSTRAINT fk2_inscricao_camp FOREIGN KEY (Administrador_CPF) REFERENCES Administrador(Usuario_CPF),
    CONSTRAINT fk3_inscricao_camp FOREIGN KEY (Espaco_Id) REFERENCES Espaco(Id)
);


-- Tabela Partida
CREATE TABLE Partida (
    Id SERIAL NOT NULL,
    Data_Hora_Inicio TIMESTAMP NOT NULL,
    Comum_CPF CHAR(11) NOT NULL,
    Espaco_Id INT NOT NULL,
    Data_Hora_Fim TIMESTAMP NOT NULL,
    Publico CHAR(1) NOT NULL,
    Esporte VARCHAR(50) NOT NULL,
    CONSTRAINT pk_partida PRIMARY KEY (Id),
    CONSTRAINT fk1_partida FOREIGN KEY (Comum_CPF) REFERENCES Comum(Usuario_CPF),
    CONSTRAINT fk2_partida FOREIGN KEY (Espaco_Id) REFERENCES Espaco(Id),
    CONSTRAINT sk_partida UNIQUE (Data_Hora_Inicio, Comum_CPF, Espaco_Id),
    CONSTRAINT chk_publico_partida CHECK (Publico IN ('A', 'F')),
    CONSTRAINT chk_data_hora_fim_partida CHECK (Data_Hora_Fim > Data_Hora_Inicio)
);


-- Tabela Aberto (Subtipo de Partida)
CREATE TABLE Aberto (
    Partida_Id INT NOT NULL,
    CONSTRAINT pk_aberto PRIMARY KEY (Partida_Id),
    CONSTRAINT fk_aberto FOREIGN KEY (Partida_Id) REFERENCES Partida(Id)
);


-- Tabela Fechado (Subtipo de Partida)
CREATE TABLE Fechado (
    Partida_Id INT NOT NULL,
    CONSTRAINT pk_fechado PRIMARY KEY (Partida_Id),
    CONSTRAINT fk_fechado FOREIGN KEY (Partida_Id) REFERENCES Partida(Id)
);


-- Tabela Participa
CREATE TABLE Participa (
    Comum_CPF CHAR(11) NOT NULL,
    Aberto_Id INT NOT NULL,
    Time_Comum VARCHAR(50) NOT NULL,
    CONSTRAINT pk_participa PRIMARY KEY (Comum_CPF, Aberto_Id),
    CONSTRAINT fk1_participa FOREIGN KEY (Comum_CPF) REFERENCES Comum(Usuario_CPF),
    CONSTRAINT fk2_participa FOREIGN KEY (Aberto_Id) REFERENCES Aberto(Partida_Id)
);


-- Tabela PartidaCamp (Relação entre Campeonato e Partida)
CREATE TABLE PartidaCamp (
    Fechado_Id INT NOT NULL,
    Administrador_CPF CHAR(11) NOT NULL,
    Espaco_Id INT NOT NULL,
    Data_Hora_Inicio TIMESTAMP NOT NULL,
    CONSTRAINT pk_partida_camp PRIMARY KEY (Fechado_Id),
    CONSTRAINT fk1_partida_camp FOREIGN KEY (Fechado_Id) REFERENCES Fechado(Partida_Id),
    CONSTRAINT fk2_partida_camp FOREIGN KEY (Administrador_CPF, Espaco_Id, Data_Hora_Inicio) REFERENCES Campeonato(Administrador_CPF, Espaco_Id, Data_Hora_Inicio) ON DELETE CASCADE -- Se o campeonato for removido as aprtidas devem ser tambem
);


-- Tabela PartidaUtilizaMaterial (Relação entre Partida e Material Esportivo)
CREATE TABLE PartidaUtilizaMaterial (
    Partida_Id INT NOT NULL,
    Espaco_Id INT NOT NULL,
    Equipamento_Id INT NOT NULL,
    CONSTRAINT pk_partida_utiliza_material PRIMARY KEY (Partida_Id, Espaco_Id, Equipamento_Id),
    CONSTRAINT fk1_partida_utiliza_material FOREIGN KEY (Partida_Id) REFERENCES Partida(Id),
    CONSTRAINT fk2_partida_utiliza_material FOREIGN KEY (Espaco_Id, Equipamento_Id) REFERENCES MaterialEsportivo(Espaco_Id, Equipamento_Id) ON DELETE CASCADE
);
