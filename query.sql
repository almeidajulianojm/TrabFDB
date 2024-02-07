/* VISÃO
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
 */

/* Consulta 1 (Subconsulta): Contagem de títulos que têm mais de uma versão */
SELECT t.tituloOriginal
FROM Titulo AS t
JOIN GanhouPremio_Premios AS gp ON t.idTitulo = gp.fk_Titulo_idTitulo
JOIN Versao AS v ON t.idTitulo = v.fk_Titulo_idTitulo
WHERE gp.ganhouPremio = true
GROUP BY t.idTitulo, t.tituloOriginal
HAVING COUNT(DISTINCT v.ordemVersao) > 70;


/* Consulta 2 (Subconsulta): Nomes dos atores que atuaram no Título que ganhou prêmios na categoria mais recente */
SELECT t.tituloOriginal, gp.categoriaPremio, n.nome AS nomeAtor
FROM Titulo AS t
JOIN GanhouPremio_Premios AS gp ON (t.idTitulo = gp.fk_Titulo_idTitulo)
JOIN AtuouEm AS a ON (t.idTitulo = a.fk_Titulo_idTitulo)
JOIN Nome AS n ON (a.fk_Nome_idNome = n.idNome)
WHERE gp.categoriaPremio = (
    SELECT categoriaPremio
    FROM GanhouPremio_Premios
    WHERE ganhouPremio = true
    ORDER BY anoPremio DESC
    LIMIT 1
);


/* Consulta 3 (Group by/Having): Gêneros que têm mais de um título associado */
SELECT g.nomeGenero, COUNT(DISTINCT t.idTitulo) AS QuantidadeDeTitulos
FROM Genero AS g
JOIN EhGenero AS eg ON (g.idGenero = eg.fk_Genero_idGenero)
JOIN Titulo AS t ON (eg.fk_Titulo_idTitulo = t.idTitulo)
GROUP BY g.nomeGenero
HAVING COUNT(DISTINCT t.idTitulo) > 1;

/* Consulta 4 (Group by): Descrever envolvimento de atores em títulos premiados */
SELECT n.idNome, n.nome AS nomeAtor, COUNT(gp.idPremio) AS QuantidadeDePremios, gp.categoriaPremio as CategoriaTituloPremiado
FROM Nome AS n
JOIN AtuouEm AS a ON (n.idNome = a.fk_Nome_idNome)
JOIN GanhouPremio_Premios AS gp ON (a.fk_Titulo_idTitulo = gp.fk_Titulo_idTitulo)
WHERE gp.ganhoupremio = true
GROUP BY n.idNome, n.nome, gp.categoriaPremio;

/* Consulta 5 (Visão): Informações gerais de um filme com mais de 5 atores */
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

/* Consulta 6: Listar pessoas que escreveram e produziram títulos*/
SELECT DISTINCT  nome, v.tituloOriginal
FROM nome
JOIN trabalhou_em AS te ON (nome.idnome = te.fk_Nome_idnome)
JOIN VisaoInformacoesTitulos as v on (te.fk_Titulo_idTitulo = v.idTitulo)
WHERE te.funcao = 'writer'
      AND nome.idnome IN (SELECT DISTINCT idnome
						  FROM nome JOIN trabalhou_em AS te ON (nome.idnome = te.fk_Nome_idnome)
						  WHERE te.funcao = 'producer');

/* Consulta 7 (NOT EXISTS): Títulos de comédia das obras que ganharam um prémio */
SELECT t.idTitulo, t.tituloOriginal
FROM Titulo AS t
JOIN EhGenero AS eg ON t.idTitulo = eg.fk_Titulo_idTitulo
JOIN Genero AS g ON eg.fk_Genero_idGenero = g.idGenero
WHERE 
    g.nomeGenero = 'Comedy'
    AND NOT EXISTS (
        SELECT 1 
        FROM GanhouPremio_Premios AS gp
        WHERE gp.fk_Titulo_idTitulo = t.idTitulo
    );

/* Consulta 8: Busca pessoas que trabalharam em mais de uma música*/
SELECT
    mp.fk_Nome_idNome AS idNome,
    n.nome AS NomeProfissional,
    COUNT(DISTINCT mp.fk_Musica_idMusica) AS QuantidadeDeMusicas
FROM musicaPor AS mp
JOIN Nome AS n ON mp.fk_Nome_idNome = n.idNome
GROUP BY mp.fk_Nome_idNome, n.nome
HAVING COUNT(DISTINCT mp.fk_Musica_idMusica) > 1;
