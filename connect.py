####################################################################################################################
#
# Abrir interface: streamlit run connect.py
#
####################################################################################################################

# Bibliotecas:
import pandas as pd
import streamlit as st 
import psycopg2 as pg 
import plotly.express as px
from sqlalchemy import create_engine, text
import streamlit_antd_components as sac

# TODO Adicionar inserts do usuário;
# TODO Adicionar gatilho;
# TODO Adicionar um if buton = true: execute;

st.set_page_config(
    page_title="Trabalho de Banco de Dados",
    page_icon="🎥",
    layout="centered"
)

st.caption('# Banco de Dados IMDb')

# Conexão com a base de dados:
# conn = pg.connect(
#     host="localhost",
#     port=5432,
#     user="postgres",
#     password="12345",
#     database="trab"
# )

# cursor = conn.cursor()

engine = create_engine("postgresql://postgres:12345@localhost:5432/trab")

############################################################################################################
#Criação de abas;

tab = sac.tabs([
    sac.TabsItem(label='DB'),
    sac.TabsItem(label='Consultas s/ atributo'),
    sac.TabsItem(label='Consultas c/ atributo'),
    sac.TabsItem(label='Gatilho'),
], variant='outline', color='pink')

# Aba 'DB':
if tab == 'DB':
    table = st.selectbox('Escolha a tabela que deseja ver:', ['atuouem', 'camera', 'contemmusica', 'ehgenero', 'ganhoupremio_premios', 'genero', 'indicadopor', 'laboratorio', 'mixagemsom', 'musica', 'musicapor', 'nome', 'processocinematografico', 'temcamera', 'temlaboratorio', 'temmixagem', 'temprocessocine', 'titulo', 'trabalhou_em', 'versao'])
    
    query = f"""
        SELECT *
        FROM {table}
    """
    
    df = pd.read_sql_query(query, engine)
    st.table(df)
    #st.write(df['nomegenero'].unique().tolist())

############################################################################################################
# Aba 'Consultas s/ atributo':
if tab == 'Consultas s/ atributo':
    query = {
        "Consulta 1: Contagem de títulos que têm mais de uma 70 versões": """
            SELECT t.tituloOriginal
            FROM Titulo AS t
            JOIN GanhouPremio_Premios AS gp ON t.idTitulo = gp.fk_Titulo_idTitulo
            JOIN Versao AS v ON t.idTitulo = v.fk_Titulo_idTitulo
            WHERE gp.ganhouPremio = true
            GROUP BY t.idTitulo, t.tituloOriginal
            HAVING COUNT(DISTINCT v.ordemVersao) > 70;
        """,
        "Consulta 2: Nomes dos atores que atuaram no Título que ganhou prêmios na categoria mais recente": """
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
        """,
        "Consulta 3: Gêneros que têm mais de um título associado": """
            SELECT g.nomeGenero, COUNT(DISTINCT t.idTitulo) AS QuantidadeDeTitulos
            FROM Genero AS g
            JOIN EhGenero AS eg ON (g.idGenero = eg.fk_Genero_idGenero)
            JOIN Titulo AS t ON (eg.fk_Titulo_idTitulo = t.idTitulo)
            GROUP BY g.nomeGenero
            HAVING COUNT(DISTINCT t.idTitulo) > 1;
        """,
        "Consulta 4: Envolvimento de atores em títulos premiados": """
            SELECT n.idNome, n.nome AS nomeAtor, COUNT(gp.idPremio) AS QuantidadeDePremios, gp.categoriaPremio as CategoriaTituloPremiado
            FROM Nome AS n
            JOIN AtuouEm AS a ON (n.idNome = a.fk_Nome_idNome)
            JOIN GanhouPremio_Premios AS gp ON (a.fk_Titulo_idTitulo = gp.fk_Titulo_idTitulo)
            WHERE gp.ganhoupremio = true
            GROUP BY n.idNome, n.nome, gp.categoriaPremio;
        """,
        "Consulta 5: Informações gerais de um filme com mais de 5 atores": """
            SELECT 
                t.idTitulo, 
                t.tituloOriginal, 
                COUNT(DISTINCT ae.fk_Nome_idNome) AS ContagemAtores,
                COUNT(DISTINCT te.fk_Nome_idNome) AS ContagemOutrasFuncoes
            FROM Titulo AS t
            LEFT JOIN AtuouEm AS ae ON (t.idTitulo = ae.fk_Titulo_idTitulo)
            LEFT JOIN Trabalhou_em AS te ON (t.idTitulo = te.fk_Titulo_idTitulo)
            GROUP BY t.idTitulo, t.tituloOriginal;
        """,
        "Consulta 6: Listar pessoas que escreveram e produziram títulos": """
            SELECT DISTINCT  nome, v.tituloOriginal
            FROM nome
            JOIN trabalhou_em AS te ON (nome.idnome = te.fk_Nome_idnome)
            JOIN VisaoInformacoesTitulos as v on (te.fk_Titulo_idTitulo = v.idTitulo)
            WHERE te.funcao = 'writer'
                AND nome.idnome IN (SELECT DISTINCT idnome
                                    FROM nome JOIN trabalhou_em AS te ON (nome.idnome = te.fk_Nome_idnome)
                                    WHERE te.funcao = 'producer');
        """,
        "Consulta 7: Títulos de comédia das obras que ganharam um prémio": """
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
        """,
        "Consulta 8: Pessoas que trabalharam em mais de uma música": """
            SELECT
                mp.fk_Nome_idNome AS idNome,
                n.nome AS NomeProfissional,
                COUNT(DISTINCT mp.fk_Musica_idMusica) AS QuantidadeDeMusicas
            FROM musicaPor AS mp
            JOIN Nome AS n ON mp.fk_Nome_idNome = n.idNome
            GROUP BY mp.fk_Nome_idNome, n.nome
            HAVING COUNT(DISTINCT mp.fk_Musica_idMusica) > 1;
        """
    }
    
    consulta = st.selectbox('Escolha a consulta que deseja ver:', list(query.keys()))
    query_result = pd.read_sql_query(query[consulta], engine)

    st.table(query_result)

############################################################################################################
# Aba 'Consultas c/ atributo':
if tab == 'Consultas c/ atributo':
    st.header('Consulta 1: Contagem de títulos que têm mais de X versões') 
    count = st.slider('Escolha o número de versões:', 50, 100)
    
    query = text("""
        SELECT t.tituloOriginal
        FROM Titulo AS t
        JOIN GanhouPremio_Premios AS gp ON t.idTitulo = gp.fk_Titulo_idTitulo
        JOIN Versao AS v ON t.idTitulo = v.fk_Titulo_idTitulo
        WHERE gp.ganhouPremio = true
        GROUP BY t.idTitulo, t.tituloOriginal
        HAVING COUNT(DISTINCT v.ordemVersao) > :count
    """).bindparams(count=count)

    query_result = pd.read_sql_query(query, engine)
    st.table(query_result)
    
    ############################################################################################################
    st.header('Consulta 6: Listar pessoas que X e Y Funções em um mesmo Título')
    funcao1 = st.selectbox('Função 1:', ["writer", "director", "editor", "producer", "composer", "cinematographer", "production_designer"])
    funcao2 = st.selectbox('Função 2:', ["writer", "director", "editor", "producer", "composer", "cinematographer", "production_designer"])
    
    query = text("""
        SELECT DISTINCT  nome, v.tituloOriginal
        FROM nome
        JOIN trabalhou_em AS te ON (nome.idnome = te.fk_Nome_idnome)
        JOIN VisaoInformacoesTitulos as v on (te.fk_Titulo_idTitulo = v.idTitulo)
        WHERE te.funcao = :funcao1
            AND nome.idnome IN (SELECT DISTINCT idnome
                                    FROM nome JOIN trabalhou_em AS te ON (nome.idnome = te.fk_Nome_idnome)
                                    WHERE te.funcao = :funcao2)
    """).bindparams(funcao1=funcao1, funcao2=funcao2)

    query_result = pd.read_sql_query(query, engine)
    st.table(query_result)
    
    ############################################################################################################
    st.header('Consulta 7: Títulos de X Gênero das obras que ganharam um prémio')
    gen = st.selectbox('Escolha o gênero:', ["Action", "Adventure", "Animation", "Comedy", "Crime", "Drama", "Family", "Romance", "Sci-Fi", "Thriller", "Western"])
    
    query = text("""
        SELECT t.idTitulo, t.tituloOriginal
        FROM Titulo AS t
        JOIN EhGenero AS eg ON t.idTitulo = eg.fk_Titulo_idTitulo
        JOIN Genero AS g ON eg.fk_Genero_idGenero = g.idGenero
        WHERE 
            g.nomeGenero = :gen
            AND NOT EXISTS (
                SELECT 1 
                FROM GanhouPremio_Premios AS gp
                WHERE gp.fk_Titulo_idTitulo = t.idTitulo
                )
    """).bindparams(gen=gen)

    query_result = pd.read_sql_query(query, engine)
    st.table(query_result)

############################################################################################################
# Aba 'Gatilho':
if tab == 'Gatilho':
    
    #Valores a serem inseridos na tabela filme;
    idTitulo='TT000004'
    tituloOriginal='Meu Novo Filme'
    tipoTitulo='Filme'
    anoLancamento=2024
    duracao=120
    resumo='Um filme incrível'
    verba=5000000
    arrecUscan=2000000
    arrecSemanaus=500000
    numVotos=1000
    anoFim=2024
    arrecGlobal=10000000
    mediaVotos=9.5
    nro_ep=0
    nro_temp=1
    fk_Titulo_idTitulo=None
    
    #Dicionário com valores definidos pelo usuário;
    insert = {
        'idTitulo': idTitulo,
        'tituloOriginal': tituloOriginal,
        'tipoTitulo': tipoTitulo,
        'anoLancamento': anoLancamento,
        'duracao': duracao,
        'resumo': resumo,
        'verba': verba,
        'arrecUscan': arrecUscan,
        'arrecSemanaus': arrecSemanaus,
        'numVotos': numVotos,
        'anoFim': anoFim,
        'arrecGlobal': arrecGlobal,
        'mediaVotos': mediaVotos,
        'nro_ep': nro_ep,
        'nro_temp': nro_temp,
        'fk_Titulo_idTitulo': fk_Titulo_idTitulo
    }

    st.write(insert)
    
    #Consulta SQL para a inserção
    query = """
        INSERT INTO Titulo (
            idTitulo, tituloOriginal, tipoTitulo, anoLancamento, duracao, resumo,
            verba, arrecUscan, arrecSemanaus, numVotos, anoFim, arrecGlobal,
            mediaVotos, nro_ep, nro_temp, fk_Titulo_idTitulo
        ) VALUES (
            :idTitulo, :tituloOriginal, :tipoTitulo, :anoLancamento, :duracao, :resumo,
            :verba, :arrecUscan, :arrecSemanaus, :numVotos, :anoFim, :arrecGlobal,
            :mediaVotos, :nro_ep, :nro_temp, :fk_Titulo_idTitulo
        )
    """

    # Execute a consulta SQL com os valores
    #engine.execute(query, **insert)

    ############################################################################################################
    query = f"""
        SELECT *
        FROM titulo
    """
    
    df = pd.read_sql_query(query, engine)
    st.dataframe(df)

############################################################################################################
# Trabalho Final para a cadeira de Fundamentos de Bancos de Dados por Juliano Machado e Lucas Caíque;