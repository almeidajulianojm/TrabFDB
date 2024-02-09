/* logico_final: */

CREATE TABLE Titulo (
    idTitulo char(9) PRIMARY KEY,
    tituloOriginal varchar(300),
    tipoTitulo varchar(50),
    anoLancamento smallInt,
    duracao smallInt,
    resumo varchar(1000),
    verba int,
    arrecUscan int,
    arrecSemanaus int,
    numVotos int,
    anoFim smallInt,
    arrecGlobal int,
    mediaVotos float,
    nro_ep smallInt,
    nro_temp smallInt,
    fk_Titulo_idTitulo char(9)
);

ALTER TABLE Titulo ADD CONSTRAINT FK_Titulo_1
    FOREIGN KEY (fk_Titulo_idTitulo)
    REFERENCES Titulo (idTitulo);

CREATE TABLE Versao (
    ordemVersao smallint,
    tituloVersao varchar(300),
    linguagemVersao varchar(4),
    ehTituloOriginal bool,
    paisVersao varchar(4),
    fk_Titulo_idTitulo char(9)
);

ALTER TABLE Versao ADD CONSTRAINT FK_Versao_2
    FOREIGN KEY (fk_Titulo_idTitulo)
    REFERENCES Titulo (idTitulo)
    ON DELETE RESTRICT;

ALTER TABLE Versao
ADD PRIMARY KEY (ordemVersao, fk_titulo_idtitulo);

CREATE TABLE Nome (
    idNome char(9) PRIMARY KEY,
    nome varchar(100),
    dataNascimento smallint,
    dataMorte smallint,
    profissoesPrincipais1 varchar(100),
    profissoesPrincipais2 varchar(100),
    profissoesPrincipais3 varchar(100)
);

CREATE TABLE Musica (
    idMusica char(9) PRIMARY KEY,
    tituloMusica varchar(100)
);

CREATE TABLE MixagemSom (
    tipoMixagem varchar(50),
    idMixagemdeSom char(9) PRIMARY KEY
);

CREATE TABLE ProcessoCinematografico (
    nomeProcesso varchar(50),
    idProcessoCinematografico char(9) PRIMARY KEY
);

CREATE TABLE GanhouPremio_Premios (
    ganhouPremio bool,
    idPremio char(9) PRIMARY KEY,
    NomePremio varchar(50),
    anoPremio smallint,
    orgPremio varchar(100),
    categoriaPremio varchar(300),
    fk_Titulo_idTitulo char(9)
);

ALTER TABLE GanhouPremio_Premios ADD CONSTRAINT FK_GanhouPremio_Premios_2
    FOREIGN KEY (fk_Titulo_idTitulo)
    REFERENCES Titulo (idTitulo);

CREATE TABLE Genero (
    nomeGenero varchar(50),
    idGenero char(9) PRIMARY KEY
);

CREATE TABLE Camera (
    idCamera char(9) PRIMARY KEY,
    nomeCamera varchar(50)
);

CREATE TABLE Laboratorio (
    idLaboratorio char(9) PRIMARY KEY,
    nomeLaboratorio varchar(150)
);

CREATE TABLE temMixagem (
    fk_Titulo_idTitulo char(9),
    fk_MixagemSom_idMixagemdeSom char(9)
);

ALTER TABLE temMixagem ADD CONSTRAINT FK_temMixagem_1
    FOREIGN KEY (fk_Titulo_idTitulo)
    REFERENCES Titulo (idTitulo)
    ON DELETE RESTRICT;
 
ALTER TABLE temMixagem ADD CONSTRAINT FK_temMixagem_2
    FOREIGN KEY (fk_MixagemSom_idMixagemdeSom)
    REFERENCES MixagemSom (idMixagemdeSom)
    ON DELETE SET NULL;

CREATE TABLE AtuouEm (
    fk_Titulo_idTitulo char(9),
    fk_Nome_idNome char(9),
    Papel varchar(50),
    PRIMARY KEY (fk_Titulo_idTitulo, fk_Nome_idNome, Papel)
);

ALTER TABLE AtuouEm ADD CONSTRAINT FK_AtuouEm_2
    FOREIGN KEY (fk_Titulo_idTitulo)
    REFERENCES Titulo (idTitulo)
    ON DELETE RESTRICT;
 
ALTER TABLE AtuouEm ADD CONSTRAINT FK_AtuouEm_3
    FOREIGN KEY (fk_Nome_idNome)
    REFERENCES Nome (idNome)
    ON DELETE SET NULL;

CREATE TABLE Trabalhou_em (
    fk_Nome_idNome char(9),
    fk_Titulo_idTitulo char(9),
    funcao varchar(50),
	PRIMARY KEY (fk_Nome_idNome, fk_Titulo_idTitulo, funcao)
);

ALTER TABLE Trabalhou_em ADD CONSTRAINT FK_Trabalhou_em_2
    FOREIGN KEY (fk_Nome_idNome)
    REFERENCES Nome (idNome)
    ON DELETE RESTRICT;
 
ALTER TABLE Trabalhou_em ADD CONSTRAINT FK_Trabalhou_em_3
    FOREIGN KEY (fk_Titulo_idTitulo)
    REFERENCES Titulo (idTitulo)
    ON DELETE RESTRICT;

CREATE TABLE temProcessoCine (
    fk_ProcessoCinematografico_idProcessoCinematografico char(9),
    fk_Titulo_idTitulo char(9),
    PRIMARY KEY (fk_ProcessoCinematografico_idProcessoCinematografico, fk_Titulo_idTitulo)
);

ALTER TABLE temProcessoCine ADD CONSTRAINT FK_temProcessoCine_1
    FOREIGN KEY (fk_ProcessoCinematografico_idProcessoCinematografico)
    REFERENCES ProcessoCinematografico (idProcessoCinematografico)
    ON DELETE SET NULL;
 
ALTER TABLE temProcessoCine ADD CONSTRAINT FK_temProcessoCine_2
    FOREIGN KEY (fk_Titulo_idTitulo)
    REFERENCES Titulo (idTitulo)
    ON DELETE SET NULL;

CREATE TABLE IndicadoPor (
    fk_Nome_idNome char(9),
    fk_idPremio char(9),
    PRIMARY KEY (fk_Nome_idNome, fk_idPremio)
);

ALTER TABLE IndicadoPor ADD CONSTRAINT FK_IndicadoPor_1
    FOREIGN KEY (fk_Nome_idNome)
    REFERENCES Nome (idNome)
    ON DELETE SET NULL;
 
ALTER TABLE IndicadoPor ADD CONSTRAINT FK_IndicadoPor_2
    FOREIGN KEY (fk_idPremio)
    REFERENCES GanhouPremio_Premios (idPremio);
 

CREATE TABLE ContemMusica (
    fk_Titulo_idTitulo char(9),
    fk_Musica_idMusica char(9),
    PRIMARY KEY (fk_Titulo_idTitulo, fk_Musica_idMusica)
);

ALTER TABLE ContemMusica ADD CONSTRAINT FK_ContemMusica_1
    FOREIGN KEY (fk_Titulo_idTitulo)
    REFERENCES Titulo (idTitulo)
    ON DELETE RESTRICT;
 
ALTER TABLE ContemMusica ADD CONSTRAINT FK_ContemMusica_2
    FOREIGN KEY (fk_Musica_idMusica)
    REFERENCES Musica (idMusica)
    ON DELETE SET NULL;

CREATE TABLE EhGenero (
    fk_Genero_idGenero char(9),
    fk_Titulo_idTitulo char(9),
    PRIMARY KEY (fk_Genero_idGenero, fk_Titulo_idTitulo)
);

ALTER TABLE EhGenero ADD CONSTRAINT FK_EhGenero_1
    FOREIGN KEY (fk_Genero_idGenero)
    REFERENCES Genero (idGenero)
    ON DELETE RESTRICT;
 
ALTER TABLE EhGenero ADD CONSTRAINT FK_EhGenero_2
    FOREIGN KEY (fk_Titulo_idTitulo)
    REFERENCES Titulo (idTitulo)
    ON DELETE RESTRICT;

CREATE TABLE temCamera (
    fk_Titulo_idTitulo char(9),
    fk_Camera_idCamera char(9),
    PRIMARY KEY (fk_Titulo_idTitulo, fk_Camera_idCamera)
);

ALTER TABLE temCamera ADD CONSTRAINT FK_temCamera_1
    FOREIGN KEY (fk_Titulo_idTitulo)
    REFERENCES Titulo (idTitulo)
    ON DELETE RESTRICT;
 
ALTER TABLE temCamera ADD CONSTRAINT FK_temCamera_2
    FOREIGN KEY (fk_Camera_idCamera)
    REFERENCES Camera (idCamera)
    ON DELETE SET NULL;
 

CREATE TABLE temLaboratorio (
    fk_Titulo_idTitulo char(9),
    fk_Laboratorio_idLaboratorio char(9),
    PRIMARY KEY (fk_Titulo_idTitulo, fk_Laboratorio_idLaboratorio)
);

ALTER TABLE temLaboratorio ADD CONSTRAINT FK_temLaboratorio_1
    FOREIGN KEY (fk_Titulo_idTitulo)
    REFERENCES Titulo (idTitulo)
    ON DELETE RESTRICT;
 
ALTER TABLE temLaboratorio ADD CONSTRAINT FK_temLaboratorio_2
    FOREIGN KEY (fk_Laboratorio_idLaboratorio)
    REFERENCES Laboratorio (idLaboratorio)
    ON DELETE SET NULL;

CREATE TABLE musicaPor (
    id_Musica_por smallint PRIMARY KEY,
    fk_Musica_idMusica char(9),
    fk_Nome_idNome char(9),
    funcao varchar(50)
);
 
ALTER TABLE musicaPor ADD CONSTRAINT FK_musicaPor_2
    FOREIGN KEY (fk_Musica_idMusica)
    REFERENCES Musica (idMusica)
    ON DELETE SET NULL;
 
ALTER TABLE musicaPor ADD CONSTRAINT FK_musicaPor_3
    FOREIGN KEY (fk_Nome_idNome)
    REFERENCES Nome (idNome)
    ON DELETE SET NULL;

CREATE VIEW VisaoInformacoesTitulos AS
 SELECT 
     t.idTitulo, 
     t.tituloOriginal, 
     COUNT(DISTINCT ae.fk_Nome_idNome) AS ContagemAtores,
     COUNT(DISTINCT te.fk_Nome_idNome) AS ContagemOutrasFuncoes
 FROM Titulo AS t
 LEFT JOIN AtuouEm AS ae ON (t.idTitulo = ae.fk_Titulo_idTitulo)
 LEFT JOIN Trabalhou_em AS te ON (t.idTitulo = te.fk_Titulo_idTitulo)
 GROUP BY t.idTitulo, t.tituloOriginal;