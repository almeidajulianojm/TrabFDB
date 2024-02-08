/* Este gatilho atualiza a tabela trabalhou_em com 
   id dos atores, id dos títulos e função 'actor'.
   Evita a necessidade de inserir manualmente info.
   sobre atores em duas tabelas diferentes.*/

create or replace function insereatores_trabalhou_em()
	RETURNS trigger as $insereatores_trabalhou_em$
	BEGIN
		INSERT INTO trabalhou_em
		VALUES (new.fk_nome_idnome, new.fk_titulo_idtitulo, 'actor');
		return new;
	END;
$insereatores_trabalhou_em$ LANGUAGE 'plpgsql' 

create trigger insereatores_trabalhou_em
after insert on atuouem
for each row
execute procedure insereatores_trabalhou_em();

/* Testando trigger */

insert into atuouem values('tt0126029','nm0000098','teste')
select * from trabalhou_em where funcao='actor'
