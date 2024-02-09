/* Um gatilho que é acionado sempre que um novo titulo é inserido na tabela título. Ele irá adicionar essa entrada como a primeira versão do mesmo na tabela versão */

BEGIN;

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

COMMIT;