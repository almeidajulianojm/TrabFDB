/* Um gatilho que é acionado sempre que um novo voto é adicionado a um título.
Ele recalcula automaticamente a média de votos na tabela Titulo para refletir a
alteração. */

begin;

-- Gatilho para inserção de título
CREATE OR REPLACE FUNCTION insere_titulo_trigger()
RETURNS TRIGGER AS $insere_titulo_trigger$
BEGIN
    -- Inserir automaticamente uma versão associada ao novo título
    INSERT INTO Versao (ordemversao, tituloVersao, ehTituloOriginal, fk_Titulo_idTitulo)
    VALUES (1, NEW.tituloOriginal, true, NEW.idTitulo);

    RETURN NEW;
END;
$insere_titulo_trigger$ LANGUAGE 'plpgsql';

-- Associação do gatilho à tabela Titulo
CREATE TRIGGER insere_titulo_trigger
AFTER INSERT ON Titulo
FOR EACH ROW
EXECUTE FUNCTION insere_titulo_trigger();

commit;

-- teste 
begin;

INSERT INTO Titulo (
    idTitulo,
    tituloOriginal,
    tipoTitulo,
    anoLancamento,
    duracao,
    resumo,
    verba,
    arrecUscan,
    arrecSemanaus,
    numVotos,
    anoFim,
    arrecGlobal,
    mediaVotos,
    nro_ep,
    nro_temp,
    fk_Titulo_idTitulo
) VALUES (
    'TT000004',
    'Meu Novo Filme',
    'Filme',
    2024,
    120,
    'Um filme incrível',
    5000000,
    2000000,
    500000,
    1000,
    2024,
    10000000,
    9.5,
    0,
    1,
	NULL
);

commit;
