PACKAGE BODY CORE  IS

    CURSOR CRS_FILTROG (  PRM_CONDICOES VARCHAR2, 
                          PRM_MICRO_VISAO VARCHAR2, 
                          PRM_SCREEN VARCHAR2, 
                          PRM_OBJETO VARCHAR2, P_CONDICOES    VARCHAR2,
                               P_MICRO_VISAO  VARCHAR2,
                               P_CD_MAPA      VARCHAR2,
                               P_NR_ITEM      VARCHAR2,
                               P_CD_PADRAO    VARCHAR2,
                               P_VPAR         VARCHAR2,
                               PRM_USUARIO    VARCHAR2 ) IS

                               SELECT DISTINCT *
                               FROM (
							      SELECT  'C'                                   AS INDICE,
                                          'DWU'                                 AS CD_USUARIO,
                                          TRIM(PRM_MICRO_VISAO)                 AS MICRO_VISAO,
                                          TRIM(CD_COLUNA)                       AS CD_COLUNA,
                                          'DIFERENTE'                           AS CONDICAO,
                                          REPLACE(TRIM(CONTEUDO), '$[NOT]', '') AS CONTEUDO,
                                          'and'                                 AS LIGACAO,
                                          'float_filter_item'                   AS TIPO
                                   FROM   FLOAT_FILTER_ITEM
                                   WHERE
                                        TRIM(CD_USUARIO) = PRM_USUARIO AND
                                        TRIM(SCREEN) = TRIM(PRM_SCREEN) AND
										INSTR(TRIM(CONTEUDO), '$[NOT]') <> 0 AND
                                        TRIM(CD_COLUNA) NOT IN (SELECT CD_COLUNA FROM FILTROS WHERE CONDICAO = 'NOFLOAT' AND TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND TRIM(CD_OBJETO) = TRIM(PRM_OBJETO) AND TP_FILTRO = 'objeto') AND
                                          TRIM(CD_COLUNA) IN ( SELECT TRIM(CD_COLUNA)
                                                               FROM   MICRO_COLUNA MC
                                                               WHERE  TRIM(MC.CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO) AND
                                                                TRIM(MC.CD_COLUNA) NOT IN (SELECT DISTINCT NVL(TRIM(CD_COLUNA), 'N/A') FROM TABLE(FUN.VPIPE_PAR(PRM_CONDICOES)))
															  ) AND FUN.GETPROP(PRM_OBJETO,'FILTRO_FLOAT') = 'N'
									
									UNION ALL
									
                                  SELECT  'C'                   AS INDICE,
                                          'DWU'                 AS CD_USUARIO,
                                          TRIM(PRM_MICRO_VISAO) AS MICRO_VISAO,
                                          TRIM(CD_COLUNA)       AS CD_COLUNA,
                                          'IGUAL'               AS CONDICAO,
                                          TRIM(CONTEUDO)        AS CONTEUDO,
                                          'and'                 AS LIGACAO,
                                          'float_filter_item'   AS TIPO
                                   FROM   FLOAT_FILTER_ITEM
                                   WHERE
                                        TRIM(CD_USUARIO) = PRM_USUARIO AND
                                        TRIM(SCREEN) = TRIM(PRM_SCREEN) AND
										INSTR(TRIM(CONTEUDO), '$[NOT]') = 0 AND
                                        TRIM(CD_COLUNA) NOT IN (SELECT CD_COLUNA FROM FILTROS WHERE CONDICAO = 'NOFLOAT' AND TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND TRIM(CD_OBJETO) = TRIM(PRM_OBJETO) AND TP_FILTRO = 'objeto') AND
                                          TRIM(CD_COLUNA) IN ( SELECT TRIM(CD_COLUNA)
                                                               FROM   MICRO_COLUNA MC
                                                               WHERE  TRIM(MC.CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO) AND
                                                                TRIM(MC.CD_COLUNA) NOT IN (SELECT DISTINCT NVL(TRIM(CD_COLUNA), 'N/A') FROM TABLE(FUN.VPIPE_PAR(PRM_CONDICOES)))
															  ) AND FUN.GETPROP(PRM_OBJETO,'FILTRO_FLOAT') = 'N'
									UNION ALL
														 SELECT 'C'                   AS INDICE,
                                                                'DWU'                 AS CD_USUARIO,
                                                                TRIM(PRM_MICRO_VISAO) AS MICRO_VISAO,
                                                                TRIM(CD_COLUNA)       AS CD_COLUNA,
                                                                CD_CONDICAO           AS CONDICAO,
                                                                TRIM(CD_CONTEUDO)     AS CONTEUDO,
                                                                'and'                 AS LIGACAO,
                                                                'condicoes'           AS TIPO
                                                         FROM   TABLE(FUN.VPIPE_PAR(P_CONDICOES)) PC
                                                         WHERE  CD_COLUNA <> '1' AND (
                                                                    TRIM(CD_COLUNA) IN (
                                                                
                                                                     SELECT TRIM(CD_COLUNA)
                                                                                     FROM   MICRO_COLUNA
                                                                                     WHERE  TRIM(CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO)
																					 AND FUN.GETPROP(PRM_OBJETO,'FILTRO_DRILL') = 'N'
                                                                            UNION ALL
                                                                                     SELECT TRIM(CD_COLUNA)
                                                                                     FROM   MICRO_VISAO_FPAR
                                                                                     WHERE  TRIM(CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO))
                                                                    OR PRM_OBJETO LIKE ('COBJ%')
                                                                    
                                                                   
                                                                ) AND
																
																
																TRIM(CD_COLUNA)||TRIM(CD_CONTEUDO) NOT IN (
																	SELECT NOF.CD_COLUNA||NOF.CONTEUDO FROM   FILTROS NOF
																	WHERE  TRIM(NOF.MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND 
																	TRIM(NOF.CONDICAO) = 'NOFILTER' AND 
																	TRIM(NOF.CONTEUDO) = TRIM(PC.CD_CONTEUDO) AND 
																	TRIM(NOF.CD_OBJETO) = TRIM(PRM_OBJETO)
																)
                                                UNION ALL
                                                         SELECT 'A'                     AS INDICE,
                                                                'DWU'                   AS CD_USUARIO,
                                                                RTRIM(P_MICRO_VISAO)    AS MICRO_VISAO,
                                                                RTRIM(CD_COLUNA)        AS CD_COLUNA,
                                                                RTRIM(CONDICAO)         AS CONDICAO,
                                                                RTRIM(CONTEUDO)         AS CONTEUDO,
                                                                RTRIM(LIGACAO)          AS LIGACAO,
                                                                'deff_line_filtro'      AS TIPO
                                                        FROM    DEFF_LINE_FILTRO
                                                        WHERE   TRIM(CD_MAPA)   = P_CD_MAPA AND
                                                                TRIM(NR_ITEM)   = P_NR_ITEM AND
                                                                TRIM(CD_PADRAO) = P_CD_PADRAO
                                                UNION ALL
                                                         SELECT 'D'                     AS INDICE,
                                                                RTRIM(CD_USUARIO) AS CD_USUARIO,
                                                                RTRIM(MICRO_VISAO) AS MICRO_VISAO,
                                                                RTRIM(CD_COLUNA) AS CD_COLUNA,
                                                                RTRIM(CONDICAO)  AS CONDICAO,
                                                                RTRIM(CONTEUDO)  AS CONTEUDO,
                                                                RTRIM(LIGACAO)  AS LIGACAO,
                                                                'filtros_objeto' AS TIPO
                                                         FROM   FILTROS
                                                         WHERE  TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND 
                                                                CONDICAO <> 'NOFLOAT' AND
																CONDICAO <> 'NOFILTER' AND
                                                                ST_AGRUPADO='N' AND
                                                                TP_FILTRO = 'objeto' AND
                                                                (TRIM(CD_OBJETO) = TRIM(PRM_OBJETO) OR (TRIM(CD_OBJETO) = TRIM(PRM_SCREEN) AND NVL(FUN.GETPROP(TRIM(PRM_OBJETO),'FILTRO'), 'N/A') <> 'ISOLADO' AND NVL(FUN.GETPROP(TRIM(PRM_OBJETO),'FILTRO'), 'N/A') <> 'COM CORTE' 
			                                                    AND FUN.GETPROP(PRM_OBJETO,'FILTRO_TELA') <> 'S')) 
																
																AND
                                                                TRIM(CD_USUARIO)  = 'DWU')
                               WHERE   NOT ( TRIM(CONDICAO)='IGUAL' AND TRIM(CD_COLUNA) IN (SELECT TRIM(CD_COLUNA) FROM TABLE(FUN.VPIPE_PAR(P_VPAR))))
                               ORDER   BY TIPO, CD_USUARIO, MICRO_VISAO, CD_COLUNA, CONDICAO, CONTEUDO;

	        WS_FILTROG	CRS_FILTROG%ROWTYPE;

    FUNCTION MONTA_QUERY_DIRECT ( PRM_MICRO_VISAO		    IN  LONG	DEFAULT NULL,
							  PRM_COLUNA		        IN  LONG	DEFAULT NULL,
							  PRM_CONDICOES             IN  LONG	DEFAULT NULL,
							  PRM_RP                    IN  LONG	DEFAULT NULL,
							  PRM_COLUP                 IN  LONG	DEFAULT NULL,
							  PRM_QUERY_PIVOT           OUT LONG,
							  PRM_QUERY_PADRAO          OUT DBMS_SQL.VARCHAR2A,
							  PRM_LINHAS                OUT NUMBER,
							  PRM_NCOLUMNS              OUT DBMS_SQL.VARCHAR2_TABLE,
							  PRM_PVPULL                OUT DBMS_SQL.VARCHAR2_TABLE,
							  PRM_AGRUPADOR             IN  LONG,
							  PRM_MFILTRO               OUT DBMS_SQL.VARCHAR2_TABLE,
							  PRM_OBJETO		        IN  VARCHAR2    DEFAULT NULL,
							  PRM_ORDEM		            IN  VARCHAR2	DEFAULT '1',
							  PRM_SCREEN                IN  LONG        DEFAULT NULL,
							  PRM_CROSS                 IN  VARCHAR2 DEFAULT NULL,
							  PRM_CAB_CROSS             OUT VARCHAR2,
							  PRM_SELF                  IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS


         CURSOR CRS_FILTROG (  P_CONDICOES    VARCHAR2,
                               P_MICRO_VISAO  VARCHAR2,
                               P_CD_MAPA      VARCHAR2,
                               P_NR_ITEM      VARCHAR2,
                               P_CD_PADRAO    VARCHAR2,
                               P_VPAR         VARCHAR2,
                               PRM_USUARIO    VARCHAR2 ) IS

                               SELECT DISTINCT *
                               FROM (
							      SELECT  'C'                                   AS INDICE,
                                          'DWU'                                 AS CD_USUARIO,
                                          TRIM(PRM_MICRO_VISAO)                 AS MICRO_VISAO,
                                          TRIM(CD_COLUNA)                       AS CD_COLUNA,
                                          'DIFERENTE'                           AS CONDICAO,
                                          REPLACE(TRIM(CONTEUDO), '$[NOT]', '') AS CONTEUDO,
                                          'and'                                 AS LIGACAO,
                                          'float_filter_item'                   AS TIPO
                                   FROM   FLOAT_FILTER_ITEM
                                   WHERE
                                        TRIM(CD_USUARIO) = PRM_USUARIO AND
                                        TRIM(SCREEN) = TRIM(PRM_SCREEN) AND
										INSTR(TRIM(CONTEUDO), '$[NOT]') <> 0 AND
                                        TRIM(CD_COLUNA) NOT IN (SELECT CD_COLUNA FROM FILTROS WHERE CONDICAO = 'NOFLOAT' AND TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND TRIM(CD_OBJETO) = TRIM(PRM_OBJETO) AND TP_FILTRO = 'objeto') AND
                                          TRIM(CD_COLUNA) IN ( SELECT TRIM(CD_COLUNA)
                                                               FROM   MICRO_COLUNA MC
                                                               WHERE  TRIM(MC.CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO) AND
                                                                TRIM(MC.CD_COLUNA) NOT IN (SELECT DISTINCT NVL(TRIM(CD_COLUNA), 'N/A') FROM TABLE(FUN.VPIPE_PAR(PRM_CONDICOES)))
															  ) AND FUN.GETPROP(PRM_OBJETO,'FILTRO_FLOAT') = 'N'
									
									UNION ALL
									
                                  SELECT  'C'                   AS INDICE,
                                          'DWU'                 AS CD_USUARIO,
                                          TRIM(PRM_MICRO_VISAO) AS MICRO_VISAO,
                                          TRIM(CD_COLUNA)       AS CD_COLUNA,
                                          'IGUAL'               AS CONDICAO,
                                          TRIM(CONTEUDO)        AS CONTEUDO,
                                          'and'                 AS LIGACAO,
                                          'float_filter_item'   AS TIPO
                                   FROM   FLOAT_FILTER_ITEM
                                   WHERE
                                        TRIM(CD_USUARIO) = PRM_USUARIO AND
                                        TRIM(SCREEN) = TRIM(PRM_SCREEN) AND
										INSTR(TRIM(CONTEUDO), '$[NOT]') = 0 AND
                                        TRIM(CD_COLUNA) NOT IN (SELECT CD_COLUNA FROM FILTROS WHERE CONDICAO = 'NOFLOAT' AND TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND TRIM(CD_OBJETO) = TRIM(PRM_OBJETO) AND TP_FILTRO = 'objeto') AND
                                          TRIM(CD_COLUNA) IN ( SELECT TRIM(CD_COLUNA)
                                                               FROM   MICRO_COLUNA MC
                                                               WHERE  TRIM(MC.CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO) AND
                                                                TRIM(MC.CD_COLUNA) NOT IN (SELECT DISTINCT NVL(TRIM(CD_COLUNA), 'N/A') FROM TABLE(FUN.VPIPE_PAR(PRM_CONDICOES)))
															  ) AND FUN.GETPROP(PRM_OBJETO,'FILTRO_FLOAT') = 'N'
									UNION ALL
														 SELECT 'C'                   AS INDICE,
                                                                'DWU'                 AS CD_USUARIO,
                                                                TRIM(PRM_MICRO_VISAO) AS MICRO_VISAO,
                                                                TRIM(CD_COLUNA)       AS CD_COLUNA,
                                                                CD_CONDICAO           AS CONDICAO,
                                                                TRIM(CD_CONTEUDO)     AS CONTEUDO,
                                                                'and'                 AS LIGACAO,
                                                                'condicoes'           AS TIPO
                                                         FROM   TABLE(FUN.VPIPE_PAR(P_CONDICOES)) PC
                                                         WHERE  CD_COLUNA <> '1' AND (
                                                                    TRIM(CD_COLUNA) IN (
                                                                
                                                                     SELECT TRIM(CD_COLUNA)
                                                                                     FROM   MICRO_COLUNA
                                                                                     WHERE  TRIM(CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO)
																					 AND FUN.GETPROP(PRM_OBJETO,'FILTRO_DRILL') = 'N'
                                                                            UNION ALL
                                                                                     SELECT TRIM(CD_COLUNA)
                                                                                     FROM   MICRO_VISAO_FPAR
                                                                                     WHERE  TRIM(CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO))
                                                                    OR PRM_OBJETO LIKE ('COBJ%')
                                                                    
                                                                   
                                                                ) AND
																
																
																TRIM(CD_COLUNA)||TRIM(CD_CONTEUDO) NOT IN (
																	SELECT NOF.CD_COLUNA||NOF.CONTEUDO FROM   FILTROS NOF
																	WHERE  TRIM(NOF.MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND 
																	TRIM(NOF.CONDICAO) = 'NOFILTER' AND 
																	TRIM(NOF.CONTEUDO) = TRIM(PC.CD_CONTEUDO) AND 
																	TRIM(NOF.CD_OBJETO) = TRIM(PRM_OBJETO)
																)
                                                UNION ALL
                                                         SELECT 'A'                     AS INDICE,
                                                                'DWU'                   AS CD_USUARIO,
                                                                RTRIM(P_MICRO_VISAO)    AS MICRO_VISAO,
                                                                RTRIM(CD_COLUNA)        AS CD_COLUNA,
                                                                RTRIM(CONDICAO)         AS CONDICAO,
                                                                RTRIM(CONTEUDO)         AS CONTEUDO,
                                                                RTRIM(LIGACAO)          AS LIGACAO,
                                                                'deff_line_filtro'      AS TIPO
                                                        FROM    DEFF_LINE_FILTRO
                                                        WHERE   TRIM(CD_MAPA)   = P_CD_MAPA AND
                                                                TRIM(NR_ITEM)   = P_NR_ITEM AND
                                                                TRIM(CD_PADRAO) = P_CD_PADRAO
                                                UNION ALL
                                                         SELECT 'D'                     AS INDICE,
                                                                RTRIM(CD_USUARIO) AS CD_USUARIO,
                                                                RTRIM(MICRO_VISAO) AS MICRO_VISAO,
                                                                RTRIM(CD_COLUNA) AS CD_COLUNA,
                                                                RTRIM(CONDICAO)  AS CONDICAO,
                                                                RTRIM(CONTEUDO)  AS CONTEUDO,
                                                                RTRIM(LIGACAO)  AS LIGACAO,
                                                                'filtros_objeto' AS TIPO
                                                         FROM   FILTROS
                                                         WHERE  TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND 
                                                                CONDICAO <> 'NOFLOAT' AND
																CONDICAO <> 'NOFILTER' AND
                                                                ST_AGRUPADO='N' AND
                                                                TP_FILTRO = 'objeto' AND
                                                                (TRIM(CD_OBJETO) = TRIM(PRM_OBJETO) OR (TRIM(CD_OBJETO) = TRIM(PRM_SCREEN) AND NVL(FUN.GETPROP(TRIM(PRM_OBJETO),'FILTRO'), 'N/A') <> 'ISOLADO' AND NVL(FUN.GETPROP(TRIM(PRM_OBJETO),'FILTRO'), 'N/A') <> 'COM CORTE' 
			                                                    AND FUN.GETPROP(PRM_OBJETO,'FILTRO_TELA') <> 'S')) 
																
																AND
                                                                TRIM(CD_USUARIO)  = 'DWU')
                               WHERE   NOT ( TRIM(CONDICAO)='IGUAL' AND TRIM(CD_COLUNA) IN (SELECT TRIM(CD_COLUNA) FROM TABLE(FUN.VPIPE_PAR(P_VPAR))))
                               ORDER   BY TIPO, CD_USUARIO, MICRO_VISAO, CD_COLUNA, CONDICAO, CONTEUDO;

	        WS_FILTROG	CRS_FILTROG%ROWTYPE;
		 
		    CURSOR CRS_FILTRO_USER(PRM_USUARIO VARCHAR2) IS 
                SELECT			
		        TRIM(CD_COLUNA)   AS CD_COLUNA,
                DECODE(TRIM(CONDICAO), 'IGUAL', '=', 'DIFERENTE', '<>', 'MAIOR', '>', 'MENOR', '<', 'MAIOROUIGUAL', '>=', 'MENOROUIGUAL', '<=', 'LIKE', 'like', 'NOTLIKE', 'not like')    AS CONDICAO,
                TRIM(CONTEUDO)    AS CONTEUDO,
                LIGACAO     AS LIGACAO
                FROM   FILTROS T1
                WHERE  TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND
                TP_FILTRO = 'geral' AND
                (TRIM(CD_USUARIO) IN (PRM_USUARIO, 'DWU') OR TRIM(CD_USUARIO) IN (SELECT CD_GROUP FROM GUSERS_ITENS WHERE CD_USUARIO = PRM_USUARIO)) AND 
                ST_AGRUPADO = 'N' ORDER BY CD_COLUNA, CONDICAO, CONTEUDO;
				
			WS_FILTRO_USER CRS_FILTRO_USER%ROWTYPE;
			
			WS_FILTRO_GERAL VARCHAR2(2000);
			
			WS_FG_CONDICAO   VARCHAR2(200);
			WS_FG_COLUNA     VARCHAR2(200);
			WS_FG_CONDICAO_R VARCHAR2(200);
			WS_FG_COLUNA_R   VARCHAR2(200);
			WS_FG_CONTEUDO_R VARCHAR2(200);


         CURSOR CRS_FILTRO_A ( P_CONDICOES    VARCHAR2,
                               P_MICRO_VISAO  VARCHAR2,
                               P_CD_MAPA      VARCHAR2,
                               P_NR_ITEM      VARCHAR2,
                               P_CD_PADRAO    VARCHAR2,
                               P_VPAR         VARCHAR2,
                               PRM_USUARIO    VARCHAR2 ) IS

                              SELECT DISTINCT *
                              FROM (
                                                         SELECT 'C'                     AS INDICE,
                                                                RTRIM(CD_USUARIO)       AS CD_USUARIO,
                                                                RTRIM(MICRO_VISAO)      AS MICRO_VISAO,
                                                                RTRIM(CD_COLUNA)        AS CD_COLUNA,
                                                                RTRIM(CONDICAO)         AS CONDICAO,
                                                                RTRIM(CONTEUDO)         AS CONTEUDO,
                                                                RTRIM(LIGACAO)          AS LIGACAO
                                                         FROM   FILTROS T1
                                                         WHERE  TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND
                                                                TP_FILTRO = 'geral' AND
                                                                (TRIM(CD_USUARIO) IN (PRM_USUARIO, 'DWU') OR TRIM(CD_USUARIO) IN (SELECT CD_GROUP FROM GUSERS_ITENS WHERE CD_USUARIO = PRM_USUARIO)) AND 
                                                                ST_AGRUPADO='S'
                                                UNION ALL
                                                         SELECT 'C'                     AS INDICE,
                                                                RTRIM(CD_USUARIO)       AS CD_USUARIO,
                                                                RTRIM(MICRO_VISAO)      AS MICRO_VISAO,
                                                                RTRIM(CD_COLUNA)        AS CD_COLUNA,
                                                                RTRIM(CONDICAO)         AS CONDICAO,
                                                                RTRIM(CONTEUDO)         AS CONTEUDO,
                                                                RTRIM(LIGACAO)          AS LIGACAO
                                                         FROM   FILTROS
                                                         WHERE  TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND
                                                                ST_AGRUPADO='S' AND
                                                                CONDICAO <> 'NOFLOAT' AND
                                                                TP_FILTRO = 'objeto' AND
                                                                (
                                                                 TRIM(CD_OBJETO) = TRIM(PRM_OBJETO) OR
                                                                (TRIM(CD_OBJETO) = TRIM(PRM_SCREEN) AND FUN.GETPROP(TRIM(PRM_OBJETO),'FILTRO')<>'ISOLADO')
                                                                ) AND
                                                                RTRIM(CD_USUARIO)  = 'DWU'
                                   )
                              WHERE NOT ( TRIM(CONDICAO)='IGUAL' AND
                                    TRIM(CD_COLUNA) IN (SELECT TRIM(CD_COLUNA) FROM TABLE(FUN.VPIPE_PAR(P_VPAR))))

                              ORDER BY CD_USUARIO, MICRO_VISAO, CD_COLUNA, CONDICAO, CONTEUDO;

	     WS_FILTRO_A          CRS_FILTRO_A%ROWTYPE;

	     CURSOR CRS_COLUNAS ( NM_AGRUPADOR VARCHAR2 ) IS

                              SELECT RTRIM(CD_COLUNA) 	  AS CD_COLUNA,
                                     DECODE(RTRIM(ST_AGRUPADOR),'MED','MEDIAN','MOD','STATS_MODE',RTRIM(ST_AGRUPADOR))
                                                          AS ST_AGRUPADOR,
                                     RTRIM(CD_LIGACAO)    AS CD_LIGACAO,
                                     RTRIM(ST_COM_CODIGO)	AS ST_COM_CODIGO,
                                     RTRIM(TIPO)		      AS TIPO,
                                     RTRIM(FORMULA)		    AS FORMULA
                              FROM   MICRO_COLUNA
                              WHERE  RTRIM(CD_MICRO_VISAO) = RTRIM(PRM_MICRO_VISAO) AND
                                     RTRIM(CD_COLUNA)      = RTRIM(NM_AGRUPADOR);

         WS_COLUNAS           CRS_COLUNAS%ROWTYPE;

         CURSOR CRS_EIXO ( NM_VAR VARCHAR2 ) IS

                           SELECT	RTRIM(CD_COLUNA)        AS DT_CD_COLUNA,
                                    DECODE(RTRIM(ST_AGRUPADOR),'MED','MEDIAN','MOD','STATS_MODE',RTRIM(ST_AGRUPADOR))
                                                            AS DT_ST_AGRUPADOR,
                                    RTRIM(CD_LIGACAO)       AS DT_CD_LIGACAO,
                                    RTRIM(ST_COM_CODIGO)    AS DT_COM_CODIGO,
                                    RTRIM(TIPO)             AS TIPO,
                                    RTRIM(FORMULA)          AS FORMULA
                                    FROM 	MICRO_COLUNA
                                    WHERE	RTRIM(CD_MICRO_VISAO) = PRM_MICRO_VISAO AND
                                    RTRIM(CD_COLUNA)      = RTRIM(NM_VAR);

         WS_EIXO		CRS_EIXO%ROWTYPE;

         CURSOR CRS_TABELA IS
                        SELECT NM_TABELA
                        FROM   MICRO_VISAO
                        WHERE  NM_MICRO_VISAO = PRM_MICRO_VISAO;

         TYPE WS_TMCOLUNAS IS TABLE OF	MICRO_COLUNA%ROWTYPE
                           INDEX BY PLS_INTEGER;

         WS_TABELA      CRS_TABELA%ROWTYPE;

         CURSOR CRS_LCALC IS
                        SELECT CD_OBJETO,
                               CD_MICRO_VISAO,
                               CD_COLUNA,
                               CD_COLUNA_SHOW||'[LC]' AS CD_COLUNA_SHOW,
                               DS_COLUNA_SHOW,
                               DS_FORMULA
                        FROM   LINHA_CALCULADA
                        WHERE  CD_OBJETO      = PRM_OBJETO AND
                               CD_MICRO_VISAO = PRM_MICRO_VISAO;

         WS_LCALC       CRS_LCALC%ROWTYPE;

         CURSOR CRS_FPAR IS
                       SELECT CD_COLUNA,
                              CD_PARAMETRO
                       FROM   MICRO_VISAO_FPAR
                       WHERE  CD_MICRO_VISAO = PRM_MICRO_VISAO
                       ORDER BY CD_COLUNA;

         WS_FPAR       CRS_FPAR%ROWTYPE;

         TYPE          GENERIC_CURSOR IS   REF CURSOR;
         CRS_SAIDA     GENERIC_CURSOR;

    TYPE               COLTP_ARRAY IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(4000);
    WS_COL_HAVING      COLTP_ARRAY;

	WS_PVCOLUMNS                 DBMS_SQL.VARCHAR2_TABLE;
	WS_AGRUPADORES               DBMS_SQL.VARCHAR2_TABLE;

    WS_NM_LABEL                  DBMS_SQL.VARCHAR2_TABLE;
    WS_NM_ORIGINAL               DBMS_SQL.VARCHAR2_TABLE;
    WS_TP_LABEL                  DBMS_SQL.VARCHAR2_TABLE;
    WS_PRM_QUERY_PADRAO          DBMS_SQL.VARCHAR2A;


    RET_MCOL                     WS_TMCOLUNAS;

    RET_COLUP                    LONG;
    RET_LCROSS                   VARCHAR2(4000);
	WS_CALCULADAS                NUMBER := 0;
    WS_CT_LABEL                  NUMBER := 0;
	WS_COUNTER                   NUMBER := 1;
	WS_CTCOLUMN                  NUMBER := 1;
	WS_CONTADOR                  NUMERIC(3);
	WS_NLABEL                    VARCHAR2(2000);
	WS_PIPE                      CHAR(1);
	WS_VIRGULA                   CHAR(1);
	WS_ENDGRP                    CHAR(3);
	WS_BINDN                     NUMBER;
	WS_BINDNS                     NUMBER;
	WS_LQUERY                    NUMBER := 1;
	WS_VCOLS                     NUMBER := 0;
	WS_CCOLUNA                   NUMBER;
	WS_LINHAS                    NUMBER;
	WS_CTLIST                    NUMBER;
	WS_VCOUNT                    NUMBER;
	WS_CTFIX                     NUMBER;
	WS_PCURSOR                   INTEGER;
	WS_XOPERADOR                 VARCHAR2(10);
	WS_CD_COLUNA_ANT             VARCHAR2(2000);
	WS_NOLOOP                    VARCHAR2(10);
    WS_UNIONALL                  VARCHAR2(2000);
	WS_CONDICAO_ANT              VARCHAR2(2000);
	WS_LIGACAO_ANT               VARCHAR2(2000);
	WS_IDENTIFICADOR             VARCHAR2(2000);
	WS_CONTEUDO_ANT              VARCHAR2(2000);
    WS_TIPO_ANT                  VARCHAR2(2000);
	WS_INDICE_ANT                VARCHAR2(5);
	WS_INITIN                    VARCHAR2(20);
	WS_TMP_CONDICAO              VARCHAR2(2000);
	WS_TMP_COL                   VARCHAR2(28000);
	WS_TCONDICAO                 VARCHAR2(2000);
	WS_LIGWHERE                  VARCHAR2(10);
	WS_PAR_FUNCTION              VARCHAR2(3000);
    WS_COLUNA_PRINCIPAL          VARCHAR2(3000)       :=  NULL;

	WS_DC_INICIO                 LONG;
	WS_DC_FINAL                  LONG;
	WS_CURSOR                    LONG;
	WS_COLUNA                    LONG;
	WS_DISTINTOS                 LONG;
	WS_ORDEM                     LONG;
	WS_GRUPO                     LONG;
	WS_GROUPING                  LONG;
	WS_AGRUPADOR                 LONG;
	WS_GORDER                    LONG;
	WS_GORD_R                    LONG;
	WS_AUX                       LONG := 'OK';

	CRLF                         VARCHAR2( 2 ):= CHR( 13 ) || CHR( 10 );

	WS_NULO                      LONG;
	WS_DCOLUNA                   LONG;
	WS_TEXTO                     LONG;
	WS_TEXTOT                    LONG;
	WS_CM_VAR                    LONG;
	WS_NM_VAR                    LONG;
	WS_CT_VAR                    LONG;
	WS_CONDICOES                 LONG;
	WS_CONDICOES_SELF            LONG;
	WS_HAVING                    LONG;
	WS_DESC_GRP                  LONG;
	WS_MFILTRO                   LONG;
	WS_CONTEUDO_COMP             LONG;
	WS_P_MICRO_VISAO             LONG   := '';
	WS_P_CD_MAPA                 LONG   := '';
	WS_P_NR_ITEM                 LONG   := '';
	WS_P_CD_PADRAO               LONG   := '';
    WS_CHECK_COLUMNS             VARCHAR2(4000);
    WS_OPTTABLE                  VARCHAR2(8000);
    WS_SUB                       VARCHAR2(80);
    WS_SELF                      VARCHAR2(1000);
    WS_FILTRO_SUB                VARCHAR2(2000);
    WS_COLUNA_FORMULA            VARCHAR2(800);
    WS_COLUNA_DIM                VARCHAR2(80);
    WS_USUARIO                   VARCHAR2(80);
    WS_ORDEM_USER                VARCHAR2(80);

	WS_VAZIO                     BOOLEAN := TRUE;
	WS_NODATA                    EXCEPTION;
    WS_NOUSER                    EXCEPTION;

  WS_ZEBRA NUMBER;
  WS_TOP_N NUMBER := 0;
 

BEGIN

    
    WS_USUARIO := GBL.GETUSUARIO;

    IF NVL(WS_USUARIO, 'NOUSER') = 'NOUSER' THEN
		RAISE WS_NOUSER;
	END IF;

    WS_SELF := REPLACE(PRM_SELF, 'SUB_', '');

    PRM_CAB_CROSS := '';

   
	SELECT COUNT(*) INTO WS_CALCULADAS
	FROM   LINHA_CALCULADA
	WHERE  CD_OBJETO      = PRM_OBJETO AND
	       CD_MICRO_VISAO = PRM_MICRO_VISAO;

	IF LENGTH(WS_SELF) > 0 THEN
	    WS_CALCULADAS := 0;
	END IF;

    WS_PAR_FUNCTION := '';
    WS_PIPE := '';

    OPEN CRS_FPAR;
        LOOP
            FETCH CRS_FPAR INTO WS_FPAR;
            EXIT WHEN CRS_FPAR%NOTFOUND;
            WS_PAR_FUNCTION := WS_PAR_FUNCTION||WS_PIPE||WS_FPAR.CD_COLUNA||'|'||WS_FPAR.CD_PARAMETRO;
            WS_PIPE         := '|';
        END LOOP;
    CLOSE CRS_FPAR;


    IF  PRM_RP = 'SUMARY' THEN
        WS_AGRUPADORES(1) := SUBSTR(PRM_CONDICOES||'|'||WS_SELF, 1 ,INSTR(PRM_CONDICOES||'|'||WS_SELF,'|')-1);
    ELSE
        WS_DISTINTOS      := FUN.RET_LIST(PRM_AGRUPADOR, WS_AGRUPADORES);
    END IF;

    WS_DISTINTOS := ' ';
    WS_GORDER    := ' ';
    WS_GORD_R    := ' ';

    WS_GROUPING  := '';
	WS_AGRUPADOR := PRM_AGRUPADOR;
	WS_DCOLUNA   := PRM_COLUNA;


    IF LENGTH(WS_SELF) > 0 THEN
        WS_SUB := SUBSTR(WS_SELF, 0, INSTR(WS_SELF, '|')-1);
    END IF;

    IF  PRM_RP = 'CUBE' THEN
        WS_GRUPO := 'group by cube(';
	    WS_ORDEM := 'order by ';
    END IF;

    IF  PRM_RP = 'ROLL' THEN
        WS_GRUPO := 'group by rollup(';
    END IF;

    IF  PRM_RP = 'GROUP' THEN
        WS_GRUPO := 'group by (';
    END IF;

    IF  PRM_RP = 'SUMARY' THEN
        WS_DCOLUNA := 'NO';
    END IF;

    OPEN CRS_TABELA;
    FETCH CRS_TABELA INTO WS_TABELA;
    CLOSE CRS_TABELA;

    WS_OPTTABLE := WS_TABELA.NM_TABELA;

    WS_DISTINTOS     := '';
    WS_PIPE          := '';
    WS_TEXTO         := WS_DCOLUNA;
    WS_TEXTOT        := WS_TEXTO;
    WS_CHECK_COLUMNS := '';


	LOOP
        IF  WS_TEXTOT = '%END%' OR WS_TEXTOT = 'NO'  THEN
            EXIT;
        END IF;

        IF  INSTR(WS_TEXTOT,'|') = 0 THEN
            WS_NM_VAR := WS_TEXTOT;
            WS_TEXTOT := '%END%';
        ELSE
             WS_TEXTO  := WS_TEXTOT;
            WS_NM_VAR := '##'||SUBSTR(WS_TEXTOT, 1 ,INSTR(WS_TEXTO,'|')-1);
            
            WS_TEXTOT := REPLACE('##'||WS_TEXTO, WS_NM_VAR||'|', '');
            WS_NM_VAR := REPLACE(WS_NM_VAR, '##', '');
        END IF;

        CASE SUBSTR(WS_NM_VAR,1,2)
            WHEN '&[' THEN
                             WS_CM_VAR := REPLACE(SUBSTR(WS_NM_VAR,1,INSTR(WS_NM_VAR,'][')-1),'&[','');
                             WS_NM_VAR := SUBSTR(WS_NM_VAR,INSTR(WS_NM_VAR,'][')+2,((LENGTH(WS_NM_VAR))-(INSTR(WS_NM_VAR,'][')+2)));
                             
                             IF  SUBSTR(WS_CM_VAR,1,5)='EXEC=' THEN
                                 WS_CM_VAR := SUBSTR(WS_CM_VAR,6,LENGTH(SUBSTR(WS_CM_VAR,6,LENGTH(WS_CM_VAR))));
                             ELSE
                                 WS_CM_VAR := ' '||FUN.SUBVAR(WS_CM_VAR)||' ';
                             END IF;

              WHEN '#[' THEN
                             WS_CM_VAR := REPLACE(SUBSTR(WS_NM_VAR,1,INSTR(WS_NM_VAR,'][')-1),'#[','');
                             WS_NM_VAR := SUBSTR(WS_NM_VAR,INSTR(WS_NM_VAR,'][')+2,((LENGTH(WS_NM_VAR))-(INSTR(WS_NM_VAR,'][')+2)));
              ELSE
                             WS_CM_VAR := 'NO_HINT';
        END CASE;

        IF  WS_CM_VAR = 'NO_HINT' THEN
            OPEN  CRS_EIXO(WS_NM_VAR);
            FETCH CRS_EIXO INTO WS_EIXO;
            CLOSE CRS_EIXO;
        ELSE
            WS_EIXO.DT_CD_COLUNA    := WS_NM_VAR;
            WS_EIXO.DT_ST_AGRUPADOR := 'SEM';
            WS_EIXO.DT_CD_LIGACAO   := 'SEM';
            WS_EIXO.DT_COM_CODIGO   := 'N';
            WS_EIXO.TIPO            := 'C';
            WS_EIXO.FORMULA         := '';
        END IF;


        IF  WS_CM_VAR <> 'NO_HINT' THEN
            WS_EIXO.FORMULA := WS_CM_VAR;
        END IF;

        IF  TRIM(WS_EIXO.DT_ST_AGRUPADOR) = 'SEM' OR TRIM(WS_EIXO.DT_ST_AGRUPADOR) = 'EXT' THEN
                IF TRIM(WS_EIXO.DT_ST_AGRUPADOR) = 'EXT' THEN
                    WS_COLUNA_DIM := REPLACE(REPLACE(FUN.GFORMULA2(PRM_MICRO_VISAO, WS_EIXO.DT_CD_COLUNA, PRM_SCREEN, '', PRM_OBJETO), 'SEM(', ''), ')', '');
                    WS_EIXO.FORMULA := WS_COLUNA_DIM;
                ELSE
                    WS_COLUNA_DIM := WS_EIXO.DT_CD_COLUNA;
                END IF;
                PRM_NCOLUMNS(WS_CTCOLUMN) := WS_COLUNA_DIM;
                WS_CTCOLUMN  := WS_CTCOLUMN + 1;
                IF  WS_EIXO.TIPO = 'C' OR WS_CM_VAR <> 'NO_HINT' THEN

                    IF  WS_CALCULADAS > 0 THEN
                        WS_CT_LABEL                 := WS_CT_LABEL + 1;
                        WS_NM_LABEL(WS_CT_LABEL)    := 'r_'||WS_COLUNA_DIM||'_'||WS_CT_LABEL;
                        WS_NM_ORIGINAL(WS_CT_LABEL) := WS_COLUNA_DIM;
                        WS_TP_LABEL(WS_CT_LABEL)    := '1';
                        WS_NLABEL                   := '_'||WS_CT_LABEL;
                    END IF;

                    


                    WS_DISTINTOS  := WS_DISTINTOS||WS_EIXO.FORMULA||' as r_'||WS_COLUNA_DIM||WS_NLABEL||','||CRLF;

                    WS_GRUPO      := WS_GRUPO||WS_EIXO.FORMULA||',';
                    WS_GROUPING   := WS_GROUPING||WS_EIXO.FORMULA||',';
                    IF  NVL(TRIM(WS_GORDER),'SEM') = 'SEM' THEN
                        WS_GORDER := ' grouping('||WS_EIXO.FORMULA||'),';
                    ELSE
                        
                        
                        
                            WS_GORD_R := WS_GORD_R||' grouping('||WS_EIXO.FORMULA||'),';
                        
                    END IF;
                    WS_ORDEM      := WS_ORDEM||WS_EIXO.FORMULA||',';

                    IF  WS_COLUNA_PRINCIPAL IS NULL THEN
                        WS_COLUNA_PRINCIPAL := WS_EIXO.FORMULA;
                    END IF;


                ELSE

                    IF  WS_CALCULADAS > 0 THEN
                        WS_CT_LABEL                 := WS_CT_LABEL + 1;
                        WS_NM_LABEL(WS_CT_LABEL)    := 'r_'||WS_COLUNA_DIM||'_'||WS_CT_LABEL;
                        WS_NM_ORIGINAL(WS_CT_LABEL) := WS_COLUNA_DIM;
                        WS_TP_LABEL(WS_CT_LABEL)    := '1';
                        WS_NLABEL                   := '_'||WS_CT_LABEL;
                    END IF;

					WS_DISTINTOS  := WS_DISTINTOS||WS_COLUNA_DIM||' as r_'||WS_COLUNA_DIM||WS_NLABEL||','||CRLF;

                    WS_CHECK_COLUMNS := WS_CHECK_COLUMNS||WS_PIPE||WS_COLUNA_DIM;
                    WS_PIPE          := '|';

                    WS_GRUPO      := WS_GRUPO||WS_COLUNA_DIM||',';
                    WS_GROUPING   := WS_GROUPING||WS_COLUNA_DIM||',';
                    IF  NVL(TRIM(WS_GORDER),'SEM') = 'SEM' THEN
                        WS_GORDER := ' grouping('||WS_COLUNA_DIM||'),';
                    ELSE

                            WS_GORD_R := WS_GORD_R||' grouping('||WS_COLUNA_DIM||'),';
                        
                    END IF;
                    WS_ORDEM      := WS_ORDEM||WS_COLUNA_DIM||',';

                    IF  WS_COLUNA_PRINCIPAL IS NULL THEN
                        WS_COLUNA_PRINCIPAL := WS_COLUNA_DIM;
                    END IF;

		         END IF; 

         IF  TRIM(WS_EIXO.DT_CD_LIGACAO) <> 'SEM' THEN
             PRM_NCOLUMNS(WS_CTCOLUMN) := WS_EIXO.DT_CD_COLUNA;
             WS_CTCOLUMN               := WS_CTCOLUMN + 1;

             IF  WS_CALCULADAS > 0 THEN
                 WS_CT_LABEL                 := WS_CT_LABEL + 1;
                 WS_NM_LABEL(WS_CT_LABEL)    := 'fun.cdesc('||' r_'||WS_EIXO.DT_CD_COLUNA||WS_NLABEL ||','''||WS_EIXO.DT_CD_LIGACAO||''')';
                 WS_NM_ORIGINAL(WS_CT_LABEL) := WS_EIXO.DT_CD_COLUNA;
                 WS_TP_LABEL(WS_CT_LABEL)    := '2';
                 WS_NLABEL                   := '_'||WS_CT_LABEL;
             END IF;

                IF  WS_CM_VAR = 'NO_HINT' THEN
                    WS_DISTINTOS  := WS_DISTINTOS||'fun.cdesc('||WS_EIXO.DT_CD_COLUNA||','''||WS_EIXO.DT_CD_LIGACAO||''') as r_nm_'||WS_EIXO.DT_CD_COLUNA||WS_NLABEL||'_d,'||CRLF;
                ELSE
                    WS_DISTINTOS  := WS_DISTINTOS||'('''||WS_CM_VAR||''') as r_nm_'||WS_EIXO.DT_CD_COLUNA||WS_NLABEL||'_d,'||CRLF;
                END IF;
            END IF;
        END IF;
    END LOOP;

    WS_BINDN  := 1;
	WS_BINDNS  := 1;

	    WS_TEXTO     := PRM_CONDICOES;

    IF  PRM_RP = 'SUMARY' THEN
        WS_AGRUPADOR := SUBSTR(WS_TEXTO, 1 ,INSTR(WS_TEXTO,'|')-1);
        WS_TEXTO := REPLACE(WS_TEXTO, WS_AGRUPADOR||'|', '');
    END IF;

    IF  LENGTH(TRIM(PRM_SELF)) > 4 THEN 
        WS_FILTRO_SUB := WS_TEXTO||'|'||WS_SELF;
    ELSE
        WS_FILTRO_SUB := WS_TEXTO;
    END IF;

    IF  LENGTH(PRM_SELF) > 0 THEN
        WS_CD_COLUNA_ANT  := 'NOCHANGE_ID';
	    WS_LIGACAO_ANT    := 'NOCHANGE_ID';
	    WS_CONDICAO_ANT   := 'NOCHANGE_ID';
	    WS_INDICE_ANT     := 0;
	    WS_INITIN         := 'NOINIT';
        WS_TMP_CONDICAO   := '';
        WS_NOLOOP         := 'NOLOOP';
        WS_TIPO_ANT       := 'NOCHANGE_ID';
        WS_CONDICOES_SELF := WS_CONDICOES_SELF||'where ( ( ';

        WS_TEXTO := REPLACE(WS_TEXTO, '||', '|');

        OPEN CRS_FILTROG( WS_FILTRO_SUB,
                             WS_P_MICRO_VISAO,
                             WS_P_CD_MAPA,
                             WS_P_NR_ITEM,
                             WS_P_CD_PADRAO,
                             WS_PAR_FUNCTION, 
                             WS_USUARIO );
        LOOP
            FETCH CRS_FILTROG INTO WS_FILTROG;
                  EXIT WHEN CRS_FILTROG%NOTFOUND;

                  IF  FUN.VCALC(WS_FILTROG.CD_COLUNA, PRM_MICRO_VISAO) THEN
                      WS_FILTROG.CD_COLUNA := FUN.XCALC(WS_FILTROG.CD_COLUNA, WS_FILTROG.MICRO_VISAO, PRM_SCREEN);
                  END IF;

                  WS_NOLOOP := 'LOOP';

                 IF  PRM_OBJETO = '%NO_BIND%' THEN
                     WS_CONTEUDO_COMP := CHR(39)||WS_CONTEUDO_ANT||CHR(39);
                 ELSE
                     WS_CONTEUDO_COMP := ' :b'||TRIM(TO_CHAR(WS_BINDN,'00'));
                 END IF;

                

                 IF  WS_CONDICAO_ANT <> 'NOCHANGE_ID' THEN
                     IF  (WS_FILTROG.CD_COLUNA = WS_CD_COLUNA_ANT AND WS_FILTROG.TIPO=WS_TIPO_ANT) AND WS_CONDICAO_ANT IN ('IGUAL','DIFERENTE') THEN
                         IF  WS_INITIN <> 'BEGIN' THEN
                             WS_CONDICOES_SELF := WS_CONDICOES_SELF||WS_TMP_CONDICAO;
                             WS_TMP_CONDICAO := '';
                         END IF;
                         WS_INITIN := 'BEGIN';
                         WS_TMP_CONDICAO := WS_TMP_CONDICAO||WS_CONTEUDO_COMP||',';
                         WS_BINDNS := WS_BINDNS + 1;
                     ELSE
                         IF  WS_INITIN = 'BEGIN' THEN
                             WS_TMP_CONDICAO := WS_TMP_CONDICAO||WS_CONTEUDO_COMP||',';
                             WS_TMP_CONDICAO := SUBSTR(WS_TMP_CONDICAO,1,LENGTH(WS_TMP_CONDICAO)-1);
                             WS_CONDICOES_SELF := WS_CONDICOES_SELF||WS_CD_COLUNA_ANT||FCL.FPDATA(WS_CONDICAO_ANT,'IGUAL',' IN ',' NOT IN ')||'('||WS_TMP_CONDICAO||') '||WS_LIGACAO_ANT||CRLF;
                             WS_TMP_CONDICAO := '';
                             WS_INITIN := 'NOINIT';
                         ELSE
                             WS_CONDICOES_SELF := WS_CONDICOES_SELF||WS_TMP_CONDICAO;
                             WS_TMP_CONDICAO := '';
                             IF  WS_FILTROG.TIPO <> WS_TIPO_ANT THEN
                                 WS_TMP_CONDICAO := WS_TMP_CONDICAO||WS_CD_COLUNA_ANT||WS_TCONDICAO||WS_CONTEUDO_COMP||' ) '||WS_LIGACAO_ANT||' ( '||CRLF;
                             ELSE
                                 WS_TMP_CONDICAO := WS_TMP_CONDICAO||WS_CD_COLUNA_ANT||WS_TCONDICAO||WS_CONTEUDO_COMP||' '||WS_LIGACAO_ANT||' '||CRLF;
                             END IF;
                         END IF;
                         WS_BINDNS := WS_BINDNS + 1;
                     END IF;
                 END IF;

                 WS_CD_COLUNA_ANT := WS_FILTROG.CD_COLUNA;
                 WS_CONDICAO_ANT  := WS_FILTROG.CONDICAO;
                 WS_INDICE_ANT    := WS_FILTROG.INDICE;
                 WS_LIGACAO_ANT   := WS_FILTROG.LIGACAO;
                 WS_CONTEUDO_ANT  := WS_FILTROG.CONTEUDO;
                 WS_TIPO_ANT      := WS_FILTROG.TIPO;

                 CASE WS_CONDICAO_ANT
                                     WHEN 'IGUAL'        THEN WS_TCONDICAO := '=';
                                     WHEN 'DIFERENTE'    THEN WS_TCONDICAO := '<>';
                                     WHEN 'MAIOR'        THEN WS_TCONDICAO := '>';
                                     WHEN 'MENOR'        THEN WS_TCONDICAO := '<';
                                     WHEN 'MAIOROUIGUAL' THEN WS_TCONDICAO := '>=';
                                     WHEN 'MENOROUIGUAL' THEN WS_TCONDICAO := '<=';
                                     WHEN 'LIKE'         THEN WS_TCONDICAO := ' like ';
                                     WHEN 'NOTLIKE'      THEN WS_TCONDICAO := ' not like ';
                                     ELSE                     WS_TCONDICAO := '***';
                END CASE;
	      END LOOP;
          CLOSE CRS_FILTROG;

		  IF  PRM_OBJETO = '%NO_BIND%' THEN
		      WS_CONTEUDO_COMP := CHR(39)||WS_CONTEUDO_ANT||CHR(39);
		  ELSE
			  WS_CONTEUDO_COMP := ' :b'||TRIM(TO_CHAR(WS_BINDNS,'00'));
		  END IF;

		  IF WS_NOLOOP <> 'NOLOOP' THEN
		    IF  WS_INITIN = 'BEGIN' THEN
					WS_TMP_CONDICAO := WS_TMP_CONDICAO||WS_CONTEUDO_COMP||',';
					WS_TMP_CONDICAO := SUBSTR(WS_TMP_CONDICAO,1,LENGTH(WS_TMP_CONDICAO)-1);
					WS_CONDICOES_SELF := WS_CONDICOES_SELF||WS_CD_COLUNA_ANT||FCL.FPDATA(WS_CONDICAO_ANT,'IGUAL',' IN ',' NOT IN ')||'('||WS_TMP_CONDICAO||')'||CRLF;
					WS_BINDNS := WS_BINDNS + 1;
				ELSE
					WS_TMP_CONDICAO := WS_TMP_CONDICAO||WS_CD_COLUNA_ANT||WS_TCONDICAO||WS_CONTEUDO_COMP||CRLF;
					WS_CONDICOES_SELF := WS_CONDICOES_SELF||WS_TMP_CONDICAO;
					WS_BINDNS := WS_BINDNS + 1;
				END IF;
			END IF;

		  IF  SUBSTR(WS_CONDICOES_SELF,LENGTH(WS_CONDICOES_SELF)-3, 3) ='( (' THEN
              WS_CONDICOES_SELF := SUBSTR(WS_CONDICOES,1,LENGTH(WS_CONDICOES_SELF)-10)||CRLF;
          ELSE
              WS_CONDICOES_SELF := WS_CONDICOES_SELF||' ) ) ';
          END IF;

    END IF;

    WS_CD_COLUNA_ANT  := 'NOCHANGE_ID';
	WS_LIGACAO_ANT    := 'NOCHANGE_ID';
	WS_CONDICAO_ANT   := 'NOCHANGE_ID';
    WS_TIPO_ANT       := 'NOCHANGE_ID';
	WS_INDICE_ANT     := 0;
	WS_INITIN         := 'NOINIT';
    WS_TMP_CONDICAO   := '';
    WS_NOLOOP         := 'NOLOOP';
    WS_CONDICOES      := WS_CONDICOES||'where ( ( ';


    OPEN CRS_FILTROG( WS_TEXTO||'|'||WS_SELF,
                      WS_P_MICRO_VISAO,
                      WS_P_CD_MAPA,
                      WS_P_NR_ITEM,
                      WS_P_CD_PADRAO,
                      WS_PAR_FUNCTION, WS_USUARIO );
    LOOP
        FETCH CRS_FILTROG INTO WS_FILTROG;
              EXIT WHEN CRS_FILTROG%NOTFOUND;

              IF  FUN.VCALC(WS_FILTROG.CD_COLUNA, PRM_MICRO_VISAO) THEN
                  WS_FILTROG.CD_COLUNA := FUN.XCALC(WS_FILTROG.CD_COLUNA, WS_FILTROG.MICRO_VISAO, PRM_SCREEN);
              END IF;

              WS_NOLOOP := 'LOOP';

              IF  PRM_OBJETO = '%NO_BIND%' THEN
                  WS_CONTEUDO_COMP := CHR(39)||WS_CONTEUDO_ANT||CHR(39);
              ELSE
                  WS_CONTEUDO_COMP := ' :b'||TRIM(TO_CHAR(WS_BINDN,'00'));
              END IF;

              IF  WS_CONDICAO_ANT <> 'NOCHANGE_ID' THEN
                  IF  (WS_FILTROG.CD_COLUNA=WS_CD_COLUNA_ANT AND WS_FILTROG.CONDICAO=WS_CONDICAO_ANT) AND WS_CONDICAO_ANT IN ('IGUAL','DIFERENTE') THEN
                      IF  WS_INITIN <> 'BEGIN' THEN
                          WS_CONDICOES := WS_CONDICOES||WS_TMP_CONDICAO;
                          WS_TMP_CONDICAO := '';
                      END IF;
                      WS_INITIN := 'BEGIN';
                      WS_TMP_CONDICAO := WS_TMP_CONDICAO||WS_CONTEUDO_COMP||',';
                      WS_BINDN := WS_BINDN + 1;
                  ELSE
                      IF  WS_INITIN = 'BEGIN' THEN
                          WS_TMP_CONDICAO := WS_TMP_CONDICAO||WS_CONTEUDO_COMP||',';
                          WS_TMP_CONDICAO := SUBSTR(WS_TMP_CONDICAO,1,LENGTH(WS_TMP_CONDICAO)-1);
                          WS_CONDICOES := WS_CONDICOES||WS_CD_COLUNA_ANT||FCL.FPDATA(WS_CONDICAO_ANT,'IGUAL',' IN ',' NOT IN ')||'('||WS_TMP_CONDICAO||') '||WS_LIGACAO_ANT||CRLF;
                          WS_TMP_CONDICAO := '';
                          WS_INITIN := 'NOINIT';
                      ELSE
                          WS_CONDICOES := WS_CONDICOES||WS_TMP_CONDICAO;
                          WS_TMP_CONDICAO := '';
                          IF  WS_FILTROG.TIPO <> WS_TIPO_ANT THEN
                              WS_TMP_CONDICAO := WS_TMP_CONDICAO||WS_CD_COLUNA_ANT||WS_TCONDICAO||WS_CONTEUDO_COMP||' ) and ( '||CRLF;
                          ELSE
                              WS_TMP_CONDICAO := WS_TMP_CONDICAO||WS_CD_COLUNA_ANT||WS_TCONDICAO||WS_CONTEUDO_COMP||' '||WS_LIGACAO_ANT||' '||CRLF;
                          END IF;
                      END IF;
                      WS_BINDN := WS_BINDN + 1;
                  END IF;
              END IF;

              WS_CHECK_COLUMNS := WS_CHECK_COLUMNS||WS_PIPE||WS_FILTROG.CD_COLUNA;
              WS_CD_COLUNA_ANT := WS_FILTROG.CD_COLUNA;
              WS_CONDICAO_ANT  := WS_FILTROG.CONDICAO;
              WS_INDICE_ANT    := WS_FILTROG.INDICE;
              WS_LIGACAO_ANT   := WS_FILTROG.LIGACAO;
              WS_CONTEUDO_ANT  := WS_FILTROG.CONTEUDO;
              WS_TIPO_ANT      := WS_FILTROG.TIPO;

              CASE WS_CONDICAO_ANT
                                  WHEN 'IGUAL'        THEN WS_TCONDICAO := '=';
                                  WHEN 'DIFERENTE'    THEN WS_TCONDICAO := '<>';
                                  WHEN 'MAIOR'        THEN WS_TCONDICAO := '>';
                                  WHEN 'MENOR'        THEN WS_TCONDICAO := '<';
                                  WHEN 'MAIOROUIGUAL' THEN WS_TCONDICAO := '>=';
                                  WHEN 'MENOROUIGUAL' THEN WS_TCONDICAO := '<=';
                                  WHEN 'LIKE'         THEN WS_TCONDICAO := ' like ';
                                  WHEN 'NOTLIKE'      THEN WS_TCONDICAO := ' not like ';
                                  ELSE                     WS_TCONDICAO := '***';
              END CASE;
    END LOOP;

    CLOSE CRS_FILTROG;



    IF  PRM_OBJETO = '%NO_BIND%' THEN
        WS_CONTEUDO_COMP := CHR(39)||WS_CONTEUDO_ANT||CHR(39);
    ELSE
        WS_CONTEUDO_COMP := ' :b'||TRIM(TO_CHAR(WS_BINDN,'00'));
    END IF;

    IF  WS_NOLOOP <> 'NOLOOP' THEN
        IF  WS_INITIN = 'BEGIN' THEN
            WS_TMP_CONDICAO := WS_TMP_CONDICAO||WS_CONTEUDO_COMP||',';
            WS_TMP_CONDICAO := SUBSTR(WS_TMP_CONDICAO,1,LENGTH(WS_TMP_CONDICAO)-1);
            WS_CONDICOES := WS_CONDICOES||WS_CD_COLUNA_ANT||FCL.FPDATA(WS_CONDICAO_ANT,'IGUAL',' IN ',' NOT IN ')||'('||WS_TMP_CONDICAO||')'||CRLF;
            WS_BINDN := WS_BINDN + 1;
        ELSE
            WS_TMP_CONDICAO := WS_TMP_CONDICAO||WS_CD_COLUNA_ANT||WS_TCONDICAO||WS_CONTEUDO_COMP||CRLF;   
            WS_CONDICOES := WS_CONDICOES||WS_TMP_CONDICAO;
            WS_BINDN := WS_BINDN + 1;
        END IF;
    END IF;

    IF  SUBSTR(WS_CONDICOES,LENGTH(WS_CONDICOES)-3, 3) ='( (' THEN
        WS_CONDICOES := SUBSTR(WS_CONDICOES,1,LENGTH(WS_CONDICOES)-10)||CRLF;
    ELSE
        WS_CONDICOES := WS_CONDICOES||' ) ) ';
    END IF;


    WS_PAR_FUNCTION := '';
    WS_PIPE         := '';

    OPEN CRS_FPAR;
    LOOP
        FETCH CRS_FPAR INTO WS_FPAR;
              EXIT WHEN CRS_FPAR%NOTFOUND;

              WS_PAR_FUNCTION := WS_PAR_FUNCTION||WS_PIPE||WS_FPAR.CD_PARAMETRO||'=> :b'||TRIM(TO_CHAR(WS_BINDN,'00'));
              WS_BINDN        := WS_BINDN + 1;
              WS_PIPE         := ',';

    END LOOP;
    CLOSE CRS_FPAR;


    WS_GROUPING := SUBSTR(WS_GROUPING,1,LENGTH(WS_GROUPING)-1);
	    
		WS_FG_CONDICAO := 'N/A';
		WS_FG_COLUNA   := 'N/A';
	
		OPEN CRS_FILTRO_USER(WS_USUARIO);
			LOOP
				FETCH CRS_FILTRO_USER INTO WS_FILTRO_USER;
				EXIT WHEN CRS_FILTRO_USER%NOTFOUND;

                WS_COLUNA_FORMULA := TRIM(FUN.GFORMULA2(PRM_MICRO_VISAO, WS_FILTRO_USER.CD_COLUNA, PRM_SCREEN, '', ''));
				
				IF (WS_FG_CONDICAO_R = WS_FILTRO_USER.CONDICAO) AND (WS_FG_COLUNA_R = WS_COLUNA_FORMULA) AND (WS_FG_CONTEUDO_R = WS_FILTRO_USER.CONTEUDO) THEN
				    WS_FILTRO_GERAL := '';
				ELSE
				
					IF (WS_FG_CONDICAO <> WS_FILTRO_USER.CONDICAO) OR (WS_FG_COLUNA <> WS_COLUNA_FORMULA) THEN
						
						
						IF WS_FG_CONDICAO = '=' THEN
							WS_FILTRO_GERAL := WS_FILTRO_GERAL||') '||WS_FILTRO_USER.LIGACAO;
						END IF;
						
						WS_FG_CONDICAO  := TRIM(WS_FILTRO_USER.CONDICAO);
						WS_FG_COLUNA    := WS_COLUNA_FORMULA;


						IF WS_FG_CONDICAO = '=' THEN
							WS_FILTRO_GERAL := WS_FILTRO_GERAL||' '||WS_COLUNA_FORMULA||' in (';
						END IF;
						
					END IF;
					
					IF WS_FILTRO_USER.CONDICAO = '=' THEN
						WS_FILTRO_GERAL := WS_FILTRO_GERAL||''''||WS_FILTRO_USER.CONTEUDO||''',';
					ELSE 
						WS_FILTRO_GERAL := WS_FILTRO_GERAL||' '||WS_COLUNA_FORMULA||' '||WS_FILTRO_USER.CONDICAO||' '''||WS_FILTRO_USER.CONTEUDO||''' '||WS_FILTRO_USER.LIGACAO;
					END IF;

				END IF;
				
				WS_FG_CONDICAO_R := WS_FILTRO_USER.CONDICAO;
				WS_FG_COLUNA_R   := WS_COLUNA_FORMULA;
				WS_FILTRO_GERAL  := REPLACE(WS_FILTRO_GERAL, ',)', ')');
				
			END LOOP;
		CLOSE CRS_FILTRO_USER;
		
		IF WS_FG_CONDICAO = '=' THEN
			WS_FILTRO_GERAL := WS_FILTRO_GERAL||')';
		END IF;

		IF WS_FG_CONDICAO <> '=' THEN
		    WS_FILTRO_GERAL := SUBSTR(WS_FILTRO_GERAL, 0, LENGTH(WS_FILTRO_GERAL)-4);
		ELSE
		    WS_FILTRO_GERAL := REPLACE(WS_FILTRO_GERAL, ',)', ')');
		END IF;
		
		IF  NVL(PRM_COLUP,'%*') = '%*' THEN
			WS_VCOUNT := 0;
			LOOP
				WS_VCOUNT := WS_VCOUNT + 1;
				IF  WS_VCOUNT > WS_AGRUPADORES.COUNT THEN
					EXIT;
				END IF;

			    IF  WS_AGRUPADORES(WS_VCOUNT) <> 'PERC_FUNCTION' THEN
				   OPEN CRS_COLUNAS(WS_AGRUPADORES(WS_VCOUNT));
				   FETCH CRS_COLUNAS INTO WS_COLUNAS;
				   CLOSE CRS_COLUNAS;

				   WS_LQUERY := WS_LQUERY + 1;
				   WS_TMP_COL := WS_COLUNAS.CD_COLUNA;
				   IF  WS_COLUNAS.TIPO='C' THEN
					   WS_TMP_COL := FUN.GFORMULA2(PRM_MICRO_VISAO, WS_COLUNAS.CD_COLUNA, PRM_SCREEN, '', PRM_OBJETO);
				   END IF;

				   IF  WS_CALCULADAS > 0 THEN
					   WS_CT_LABEL                 := WS_CT_LABEL + 1;
					   WS_NM_LABEL(WS_CT_LABEL)    := 'r_'||WS_COLUNAS.CD_COLUNA||'_'||WS_CT_LABEL;
					   WS_NM_ORIGINAL(WS_CT_LABEL) := WS_COLUNAS.CD_COLUNA;
					   WS_TP_LABEL(WS_CT_LABEL)    := '3';
					   WS_NLABEL                   := '_'||WS_CT_LABEL;
				   END IF;

				   



				   IF  RTRIM(WS_COLUNAS.ST_AGRUPADOR) IN ('PSM','PCT','CNT') THEN
					   IF  RTRIM(WS_COLUNAS.ST_AGRUPADOR)='PSM' THEN
						   WS_COL_HAVING(WS_COLUNAS.CD_COLUNA)     := '(RATIO_TO_REPORT(SUM  ('||WS_TMP_COL||')) OVER (PARTITION BY grouping_id('||WS_GROUPING||'))*100) ';
						   PRM_QUERY_PADRAO(WS_LQUERY)             := '(RATIO_TO_REPORT(SUM  ('||WS_TMP_COL||')) OVER (PARTITION BY grouping_id('||WS_GROUPING||'))*100) as r_'||WS_COLUNAS.CD_COLUNA||WS_NLABEL||','||CRLF;
					   ELSE
						   IF  RTRIM(WS_COLUNAS.ST_AGRUPADOR)='CNT' THEN
							   WS_COL_HAVING(WS_COLUNAS.CD_COLUNA) :=  'COUNT(DISTINCT '||WS_TMP_COL||') ';
							   PRM_QUERY_PADRAO(WS_LQUERY)         := 'COUNT(DISTINCT '||WS_TMP_COL||') as r_'||WS_COLUNAS.CD_COLUNA||WS_NLABEL||','||CRLF;
						   ELSE
							   WS_COL_HAVING(WS_COLUNAS.CD_COLUNA) := '(RATIO_TO_REPORT(COUNT(DISTINCT '||WS_TMP_COL||')) OVER (PARTITION BY grouping_id('||WS_GROUPING||'))*100) ';
							   PRM_QUERY_PADRAO(WS_LQUERY)         := '(RATIO_TO_REPORT(COUNT(DISTINCT '||WS_TMP_COL||')) OVER (PARTITION BY grouping_id('||WS_GROUPING||'))*100) as r_'||WS_COLUNAS.CD_COLUNA||WS_NLABEL||','||CRLF;
						   END IF;
					   END IF;
				   ELSIF TRIM(WS_COLUNAS.ST_AGRUPADOR) = 'IMG' THEN
					   WS_COL_HAVING(WS_COLUNAS.CD_COLUNA)     := 'MAX('||WS_TMP_COL||') ';
					   PRM_QUERY_PADRAO(WS_LQUERY)         := 'MAX('||WS_TMP_COL||') as r_'||WS_COLUNAS.CD_COLUNA||WS_NLABEL||','||CRLF;
				   ELSE
					   WS_COL_HAVING(WS_COLUNAS.CD_COLUNA)         := FCL.FPDATA(RTRIM(WS_COLUNAS.ST_AGRUPADOR),'EXT','',RTRIM(WS_COLUNAS.ST_AGRUPADOR))||'('||WS_TMP_COL||') ';
					   PRM_QUERY_PADRAO(WS_LQUERY)                 := FCL.FPDATA(RTRIM(WS_COLUNAS.ST_AGRUPADOR),'EXT','',RTRIM(WS_COLUNAS.ST_AGRUPADOR))||'('||WS_TMP_COL||') as r_'||WS_COLUNAS.CD_COLUNA||WS_NLABEL||','||CRLF;
				   END IF;

				   PRM_NCOLUMNS(WS_CTCOLUMN) := WS_COLUNAS.CD_COLUNA;
				   WS_CTCOLUMN := WS_CTCOLUMN + 1;
			   END IF;
			  END LOOP;

			IF  PRM_RP = 'PIZZA' THEN
				WS_LQUERY   := WS_LQUERY + 1;
				PRM_QUERY_PADRAO(WS_LQUERY) := 'trunc((RATIO_TO_REPORT(SUM('||WS_TMP_COL||')) OVER (partition by grouping_id('||PRM_COLUNA||')))*100) as perc ';
				PRM_NCOLUMNS(WS_CTCOLUMN) := 'PERC';
				WS_CTCOLUMN := WS_CTCOLUMN + 1;
			END IF;

		   IF  NVL(TRIM(WS_GRUPO),'%NO_UNDER_GRP%') <> '%NO_UNDER_GRP%' THEN

				WS_LQUERY   := WS_LQUERY + 1;
				PRM_QUERY_PADRAO(WS_LQUERY) := 'grouping_id('||REPLACE(REPLACE(REPLACE(SUBSTR(WS_GRUPO,1,LENGTH(WS_GRUPO)-1),'group by cube(',''),'group by rollup(',''),'group by (','')||')'||' as UP_GRP_ID';
				PRM_NCOLUMNS(WS_CTCOLUMN)   := 'UP_GRP_MODEL';
				WS_CTCOLUMN := WS_CTCOLUMN + 1;
				IF TRIM(WS_COLUNA_PRINCIPAL) IS NOT NULL THEN
					PRM_QUERY_PADRAO(WS_LQUERY) := PRM_QUERY_PADRAO(WS_LQUERY)||', grouping_id('||WS_COLUNA_PRINCIPAL||') as UP_PRINCIPAL';
					PRM_NCOLUMNS(WS_CTCOLUMN)   := 'UP_PRINCIPAL';
					WS_CTCOLUMN := WS_CTCOLUMN + 1;
				END IF;
		   END IF;

		ELSE
			WS_BINDN  := 0;
			WS_TEXTO  := PRM_COLUP;
			WS_TEXTOT := ' ';

			LOOP
				WS_BINDN  := WS_BINDN + 1;
				IF  INSTR(WS_TEXTO,'|') > 0 THEN
					WS_NM_VAR            := SUBSTR(WS_TEXTO, 1 ,INSTR(WS_TEXTO,'|')-1);
					IF  FUN.VCALC(WS_NM_VAR,PRM_MICRO_VISAO) THEN
						WS_NM_VAR :=  FUN.XCALC(WS_NM_VAR,	PRM_MICRO_VISAO, PRM_SCREEN );
					END IF;
					PRM_PVPULL(WS_BINDN) := WS_NM_VAR;
                    COMMIT;
					WS_TEXTO             := REPLACE (WS_TEXTO, WS_NM_VAR||'|', '');
					WS_TEXTOT            := WS_TEXTOT||WS_NM_VAR||',';
				ELSE

					IF  FUN.VCALC(WS_TEXTO,PRM_MICRO_VISAO) THEN
						WS_TEXTO :=  FUN.XCALC(WS_TEXTO,	PRM_MICRO_VISAO, PRM_SCREEN );
					END IF;
					PRM_PVPULL(WS_BINDN) := WS_TEXTO;
                    COMMIT;
					WS_TEXTOT            := WS_TEXTOT||WS_TEXTO||',';
					EXIT;
				END IF;
			END LOOP;

			WS_TEXTOT := SUBSTR(WS_TEXTOT,1,LENGTH(WS_TEXTOT)-1);

			IF  WS_PAR_FUNCTION <> '' THEN
			    WS_CURSOR := 'select distinct '||WS_TEXTOT||' from table('||WS_OPTTABLE||'('||WS_PAR_FUNCTION||')) '||WS_CONDICOES||' order by 1';
		    ELSE
				IF  LENGTH(PRM_SELF) > 0 THEN
                    BEGIN
                    SELECT LISTAGG(REGRA||' and ') WITHIN GROUP (ORDER BY REGRA) INTO WS_CONDICOES_SELF FROM (
                        SELECT CD_COLUNA||' in ('||LISTAGG(CHR(39)||FUN.SUBPAR(CONTEUDO, PRM_SCREEN)||CHR(39), ', ') WITHIN GROUP (ORDER BY CD_COLUNA)||')' AS REGRA 
            FROM (
                SELECT  
                TRIM(CD_COLUNA) AS CD_COLUNA,
                'DIFERENTE'     AS CONDICAO,
                REPLACE(TRIM(CONTEUDO), '$[NOT]', '') AS CONTEUDO
                FROM   FLOAT_FILTER_ITEM
                WHERE
                TRIM(CD_USUARIO) = WS_USUARIO AND
                TRIM(SCREEN) = TRIM(PRM_SCREEN) AND
                INSTR(TRIM(CONTEUDO), '$[NOT]') <> 0 AND
                TRIM(CD_COLUNA) NOT IN (SELECT CD_COLUNA FROM FILTROS WHERE CONDICAO = 'NOFLOAT' AND TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND TRIM(CD_OBJETO) = TRIM(PRM_OBJETO) AND TP_FILTRO = 'objeto') AND
                TRIM(CD_COLUNA) IN ( SELECT TRIM(CD_COLUNA)
                                    FROM   MICRO_COLUNA MC
                                    WHERE  TRIM(MC.CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO) AND
                                        TRIM(MC.CD_COLUNA) NOT IN (SELECT DISTINCT NVL(TRIM(CD_COLUNA), 'N/A') FROM TABLE(FUN.VPIPE_PAR('')))
                                    ) AND FUN.GETPROP(PRM_OBJETO,'FILTRO_FLOAT') = 'N' AND
                                    CD_COLUNA = UPPER(TRIM(WS_TEXTOT))

                UNION ALL
                
                SELECT  
                    TRIM(CD_COLUNA)       AS CD_COLUNA,
                    'IGUAL'               AS CONDICAO,
                    TRIM(CONTEUDO)        AS CONTEUDO
                    
                FROM   FLOAT_FILTER_ITEM
                WHERE
                    TRIM(CD_USUARIO) = WS_USUARIO AND
                    TRIM(SCREEN) = TRIM(PRM_SCREEN) AND
                    INSTR(TRIM(CONTEUDO), '$[NOT]') = 0 AND
                    TRIM(CD_COLUNA) NOT IN (SELECT CD_COLUNA FROM FILTROS WHERE CONDICAO = 'NOFLOAT' AND TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND TRIM(CD_OBJETO) = TRIM(PRM_OBJETO) AND TP_FILTRO = 'objeto') AND
                    TRIM(CD_COLUNA) IN ( SELECT TRIM(CD_COLUNA)
                                        FROM   MICRO_COLUNA MC
                                        WHERE  TRIM(MC.CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO) AND
                                            TRIM(MC.CD_COLUNA) NOT IN (SELECT DISTINCT NVL(TRIM(CD_COLUNA), 'N/A') FROM TABLE(FUN.VPIPE_PAR('')))
                                        ) AND FUN.GETPROP(PRM_OBJETO,'FILTRO_FLOAT') = 'N' AND
                                        CD_COLUNA = UPPER(TRIM(WS_TEXTOT))
                
                            UNION ALL
                                    SELECT 
                                            RTRIM(CD_COLUNA) AS CD_COLUNA,
                                            RTRIM(CONDICAO)  AS CONDICAO,
                                            RTRIM(CONTEUDO)  AS CONTEUDO
                                        
                                    FROM   FILTROS
                                    WHERE  TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND 
                                            CONDICAO <> 'NOFLOAT' AND
                                            CONDICAO <> 'NOFILTER' AND
                                            ST_AGRUPADO='N' AND
                                            TP_FILTRO = 'objeto' AND
                                            (TRIM(CD_OBJETO) = TRIM(PRM_OBJETO) OR (TRIM(CD_OBJETO) = TRIM(PRM_SCREEN) AND NVL(FUN.GETPROP(TRIM(PRM_OBJETO),'FILTRO'), 'N/A') <> 'ISOLADO' AND NVL(FUN.GETPROP(TRIM(PRM_OBJETO),'FILTRO'), 'N/A') <> 'COM CORTE' 
                                            AND FUN.GETPROP(PRM_OBJETO,'FILTRO_TELA') <> 'S')) 
                                            
                                            AND
                                            TRIM(CD_USUARIO)  IN ('DWU', WS_USUARIO) AND
                                            CD_COLUNA = UPPER(TRIM(WS_TEXTOT))) 
                                            GROUP BY CD_COLUNA);
                        EXCEPTION WHEN OTHERS THEN
                            INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SUBQUERY', USER, 'ERRO');
                            COMMIT;
                            WS_CONDICOES_SELF := '';
                        END;

                        WS_CONDICOES_SELF := SUBSTR(TRIM(WS_CONDICOES_SELF), 0, LENGTH(TRIM(WS_CONDICOES_SELF))-3);

                    IF LENGTH(TRIM(WS_CONDICOES_SELF)) > 1 THEN
                        WS_CURSOR := 'select distinct '||WS_TEXTOT||' frOm '||WS_OPTTABLE||' where '||WS_CONDICOES_SELF||' order by 1';
                    ELSE
                        WS_CURSOR := 'select distinct '||WS_TEXTOT||' frOm '||WS_OPTTABLE||' order by 1';
                    END IF;
                ELSE
					IF LENGTH(WS_FILTRO_GERAL) > 2 THEN
						IF LENGTH(TRIM(WS_CONDICOES)) > 2 THEN
							WS_CURSOR := 'select distinct '||WS_TEXTOT||' From '||WS_OPTTABLE||' '||WS_CONDICOES||' and '||WS_FILTRO_GERAL||' order by 1';
						ELSE
							WS_CURSOR := 'select distinct '||WS_TEXTOT||' fRom '||WS_OPTTABLE||' where '||WS_FILTRO_GERAL||' order by 1';
						END IF;
					ELSE
						WS_CURSOR := 'select distinct '||WS_TEXTOT||' froM '||WS_OPTTABLE||' '||WS_CONDICOES||' order by 1';
					END IF;
				END IF;
		END IF;

        WS_PCURSOR := DBMS_SQL.OPEN_CURSOR;
        PRM_QUERY_PIVOT := WS_CURSOR;

        DBMS_SQL.PARSE(WS_PCURSOR, WS_CURSOR, DBMS_SQL.NATIVE);

        WS_BINDN := 0;

        LOOP
            WS_BINDN := WS_BINDN + 1;
            IF  WS_BINDN > PRM_PVPULL.COUNT THEN
                EXIT;
            END IF;

            DBMS_SQL.DEFINE_COLUMN(WS_PCURSOR, WS_BINDN, RET_COLUP, 40);
            
            COMMIT;
        END LOOP;

		BEGIN 
		WS_NULO := CORE.BIND_DIRECT(PRM_CONDICOES||'|'||WS_SELF, WS_PCURSOR, '', PRM_OBJETO, PRM_MICRO_VISAO, PRM_SCREEN);
		EXCEPTION WHEN OTHERS THEN
            INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - MONTA_QUERY', WS_USUARIO, 'ERRO');
            COMMIT;
		END;

        WS_LINHAS := DBMS_SQL.EXECUTE(WS_PCURSOR);

        WS_COUNTER := 0;
        WS_CCOLUNA := 0;
        WS_CTLIST  := 0;

        LOOP
            WS_LINHAS := DBMS_SQL.FETCH_ROWS(WS_PCURSOR);
            IF  WS_LINHAS = 1 THEN
                WS_VAZIO := FALSE;
            ELSE
                IF  WS_VAZIO = TRUE THEN
                    DBMS_SQL.CLOSE_CURSOR(WS_PCURSOR);
                    RAISE WS_NODATA;
                END IF;
                EXIT;
            END IF;
            
            
            WS_MFILTRO   := '';
            WS_BINDN     := 0;
            WS_DC_INICIO := ' ';
            WS_DC_FINAL  := ' ';
            WS_DESC_GRP  := '';
            WS_PIPE	     := '';
            
            LOOP
                WS_BINDN := WS_BINDN + 1;
                IF  WS_BINDN > PRM_PVPULL.COUNT THEN
                    EXIT;
                END IF;

                WS_MFILTRO   := WS_MFILTRO||WS_PIPE;
                DBMS_SQL.COLUMN_VALUE(WS_PCURSOR, WS_BINDN, RET_COLUP);
                WS_DC_INICIO := WS_DC_INICIO||'decode('||PRM_PVPULL(WS_BINDN)||','''||RET_COLUP||''',';
                WS_DC_FINAL  := WS_DC_FINAL||',null)';
                WS_DESC_GRP  := WS_DESC_GRP||'_'||RET_COLUP;
                WS_CTLIST    := WS_CTLIST + 1;
                WS_MFILTRO   := WS_MFILTRO||PRM_PVPULL(WS_BINDN)||'|'||RET_COLUP;
                WS_PIPE      := '|';
            END LOOP;
            
            WS_VCOUNT := 0;
            LOOP
                WS_VCOUNT := WS_VCOUNT + 1;
                IF  WS_VCOUNT > WS_AGRUPADORES.COUNT THEN
                    EXIT;
                END IF;

                IF  WS_AGRUPADORES(WS_VCOUNT) <> 'PERC_FUNCTION'  THEN

                    OPEN CRS_COLUNAS(WS_AGRUPADORES(WS_VCOUNT));
                    FETCH CRS_COLUNAS INTO WS_COLUNAS;
                    CLOSE CRS_COLUNAS;

                    WS_LQUERY := WS_LQUERY + 1;
                    WS_TMP_COL := WS_COLUNAS.CD_COLUNA;
                    IF  WS_COLUNAS.TIPO='C' THEN
                        IF  RTRIM(WS_COLUNAS.ST_AGRUPADOR) <> 'EXT' THEN
                            WS_TMP_COL := WS_DC_INICIO||FUN.GFORMULA2(PRM_MICRO_VISAO, WS_COLUNAS.CD_COLUNA, PRM_SCREEN, '', PRM_OBJETO)||WS_DC_FINAL;
                        ELSE

                            WS_TMP_COL := FUN.GFORMULA2(PRM_MICRO_VISAO, WS_COLUNAS.CD_COLUNA, PRM_SCREEN, '', PRM_OBJETO, WS_DC_INICIO, WS_DC_FINAL);
                        END IF;
                    ELSE
                        WS_TMP_COL := WS_DC_INICIO||WS_TMP_COL||WS_DC_FINAL;
                    END IF;
                    
                END IF;

                IF  WS_CALCULADAS > 0 THEN
                    WS_CT_LABEL                 := WS_CT_LABEL + 1;
                    WS_NM_LABEL(WS_CT_LABEL)    := 'r_'||WS_COLUNAS.CD_COLUNA||'_'||WS_CT_LABEL;
                    WS_NM_ORIGINAL(WS_CT_LABEL) := WS_COLUNAS.CD_COLUNA;
                    WS_TP_LABEL(WS_CT_LABEL)    := '3';
                    WS_NLABEL                   := '_'||WS_CT_LABEL;
                END IF;

                IF  RTRIM(WS_COLUNAS.ST_AGRUPADOR) IN ('PSM','PCT','CNT') THEN
                    IF  RTRIM(WS_COLUNAS.ST_AGRUPADOR)='PSM' THEN
                        PRM_QUERY_PADRAO(WS_LQUERY)     := 'trunc((RATIO_TO_REPORT(SUM('||WS_TMP_COL||')) OVER ()*100)) as r_'||WS_COLUNAS.CD_COLUNA||WS_NLABEL||','||CRLF;
                    ELSE
                        IF  RTRIM(WS_COLUNAS.ST_AGRUPADOR)='CNT' THEN
                            PRM_QUERY_PADRAO(WS_LQUERY) := 'COUNT(DISTINCT '||WS_TMP_COL||') as r_'||WS_COLUNAS.CD_COLUNA||','||CRLF;
                        ELSE
                            PRM_QUERY_PADRAO(WS_LQUERY) := 'trunc((RATIO_TO_REPORT(COUNT(DISTINCT '||WS_TMP_COL||')) OVER ()*100)) as r_'||WS_COLUNAS.CD_COLUNA||WS_NLABEL||','||CRLF;
                        END IF;
                    END IF;
                ELSE
                    PRM_QUERY_PADRAO(WS_LQUERY)         := FCL.FPDATA(RTRIM(WS_COLUNAS.ST_AGRUPADOR),'EXT','',TRIM(WS_COLUNAS.ST_AGRUPADOR))||'('||WS_TMP_COL||') aS r_'||WS_COLUNAS.CD_COLUNA||WS_NLABEL||','||CRLF;
                END IF;

              PRM_NCOLUMNS(WS_CTCOLUMN) := WS_COLUNAS.CD_COLUNA;
              WS_CTCOLUMN               := WS_CTCOLUMN + 1;
              PRM_MFILTRO(WS_CTCOLUMN)  := WS_MFILTRO;
              WS_VCOLS                  := WS_VCOLS    + 1;
		    END LOOP;
        END LOOP;

        
        IF  PRM_PVPULL.COUNT > 0 AND FUN.GETPROP(PRM_OBJETO,'NO_TUP') <> 'S' THEN
            WS_VCOUNT := 0;
            LOOP
                WS_VCOUNT := WS_VCOUNT + 1;
                IF  WS_VCOUNT > WS_AGRUPADORES.COUNT THEN
                    EXIT;
                END IF;
                IF  WS_AGRUPADORES(WS_VCOUNT) <> 'PERC_FUNCTION'  THEN
                    OPEN CRS_COLUNAS(WS_AGRUPADORES(WS_VCOUNT));
                    FETCH CRS_COLUNAS INTO WS_COLUNAS;
                    CLOSE CRS_COLUNAS;

                    WS_LQUERY := WS_LQUERY + 1;
                    WS_TMP_COL := WS_COLUNAS.CD_COLUNA;
                    IF  WS_COLUNAS.TIPO='C' THEN
                        WS_TMP_COL := FUN.GFORMULA2(PRM_MICRO_VISAO, WS_COLUNAS.CD_COLUNA, PRM_SCREEN, '', PRM_OBJETO);
                    ELSE
                        WS_TMP_COL := '('||WS_TMP_COL||')';
                    END IF;
                END IF;

                IF  WS_CALCULADAS > 0 THEN
                    WS_CT_LABEL                 := WS_CT_LABEL + 1;
                    WS_NM_LABEL(WS_CT_LABEL)    := 'r_'||WS_COLUNAS.CD_COLUNA||'_'||WS_CT_LABEL;
                    WS_NM_ORIGINAL(WS_CT_LABEL) := WS_COLUNAS.CD_COLUNA;
                    WS_TP_LABEL(WS_CT_LABEL)    := '3';
                    WS_NLABEL                   := '_'||WS_CT_LABEL;
                END IF;

                IF  RTRIM(WS_COLUNAS.ST_AGRUPADOR) IN ('PSM','PCT','CNT') THEN
                    IF  RTRIM(WS_COLUNAS.ST_AGRUPADOR)='PSM' THEN
                        PRM_QUERY_PADRAO(WS_LQUERY)     := 'trunc((RATIO_TO_REPORT(SUM('||WS_TMP_COL||')) OVER ()*100)) as r_'||WS_COLUNAS.CD_COLUNA||WS_NLABEL||','||CRLF;
                    ELSE
                        IF  RTRIM(WS_COLUNAS.ST_AGRUPADOR)='CNT' THEN
                            PRM_QUERY_PADRAO(WS_LQUERY) := 'COUNT(DISTINCT '||WS_TMP_COL||') as r_'||WS_COLUNAS.CD_COLUNA||WS_NLABEL||','||CRLF;
                        ELSE
                            PRM_QUERY_PADRAO(WS_LQUERY) := 'trunc((RATIO_TO_REPORT(COUNT(DISTINCT '||WS_TMP_COL||')) OVER ()*100)) as r_'||WS_COLUNAS.CD_COLUNA||WS_NLABEL||','||CRLF;
                        END IF;
                    END IF;
                ELSE
                    PRM_QUERY_PADRAO(WS_LQUERY) := FCL.FPDATA(RTRIM(WS_COLUNAS.ST_AGRUPADOR),'EXT','',RTRIM(WS_COLUNAS.ST_AGRUPADOR))||'('||WS_TMP_COL||') As r_'||WS_COLUNAS.CD_COLUNA||WS_NLABEL||','||CRLF;
                END IF;

                PRM_NCOLUMNS(WS_CTCOLUMN) := WS_COLUNAS.CD_COLUNA;
                PRM_MFILTRO(WS_CTCOLUMN)  := WS_MFILTRO;
                WS_CTCOLUMN := WS_CTCOLUMN + 1;
                WS_VCOLS    := WS_VCOLS    + 1;
            END LOOP;

        END IF;

	    IF  NVL(TRIM(WS_GRUPO),'%NO_UNDER_GRP%') <> '%NO_UNDER_GRP%' THEN
            WS_LQUERY   := WS_LQUERY + 1;
            PRM_QUERY_PADRAO(WS_LQUERY) := 'grouping_id('||REPLACE(REPLACE(REPLACE(SUBSTR(WS_GRUPO,1,LENGTH(WS_GRUPO)-1),'group by cube(',''),'group by rollup(',''),'group by (','')||')'||' as UP_GRP_ID';
			PRM_NCOLUMNS(WS_CTCOLUMN)   := 'UP_GRP_MODEL';
            WS_CTCOLUMN := WS_CTCOLUMN + 1;


            IF  TRIM(WS_COLUNA_PRINCIPAL) IS NOT NULL THEN
                PRM_QUERY_PADRAO(WS_LQUERY) := PRM_QUERY_PADRAO(WS_LQUERY)||', grouping_id('||WS_COLUNA_PRINCIPAL||') as UP_PRINCIPAL';
                PRM_NCOLUMNS(WS_CTCOLUMN)   := 'UP_PRINCIPAL';
                WS_CTCOLUMN := WS_CTCOLUMN + 1;
            END IF;

        END IF;

        DBMS_SQL.CLOSE_CURSOR(WS_PCURSOR);
    END IF;


    WS_CD_COLUNA_ANT  := 'NOCHANGE_ID';
    WS_LIGACAO_ANT    := 'NOCHANGE_ID';
    WS_CONDICAO_ANT   := 'NOCHANGE_ID';
    WS_INDICE_ANT     := 0;
    WS_INITIN         := 'NOINIT';
    WS_TMP_CONDICAO   := '';
    WS_NOLOOP         := 'NOLOOP';
    WS_HAVING         := 'having ( ( ';

    OPEN CRS_FILTRO_A( WS_TEXTO,
                       WS_P_MICRO_VISAO,
                       WS_P_CD_MAPA,
                       WS_P_NR_ITEM,
                       WS_P_CD_PADRAO,
                       WS_PAR_FUNCTION,
                       WS_USUARIO );
    LOOP
        FETCH CRS_FILTRO_A INTO WS_FILTRO_A;
              EXIT WHEN CRS_FILTRO_A%NOTFOUND;

              WS_FILTRO_A.CD_COLUNA := WS_COL_HAVING(WS_FILTRO_A.CD_COLUNA);
              WS_NOLOOP := 'LOOP';
              IF  PRM_OBJETO = '%NO_BIND%' THEN
                  WS_CONTEUDO_COMP := CHR(39)||WS_CONTEUDO_ANT||CHR(39);
              ELSE
                  WS_CONTEUDO_COMP := ' :b'||TRIM(TO_CHAR(WS_BINDN,'00'));
              END IF;

              IF  WS_CONDICAO_ANT <> 'NOCHANGE_ID' THEN
                  IF  (WS_FILTRO_A.CD_COLUNA=WS_CD_COLUNA_ANT AND WS_FILTRO_A.CONDICAO=WS_CONDICAO_ANT) AND WS_CONDICAO_ANT IN ('IGUAL','DIFERENTE') THEN
                      IF  WS_INITIN <> 'BEGIN' THEN
                          WS_HAVING := WS_HAVING||WS_TMP_CONDICAO;
                          WS_TMP_CONDICAO := '';
                      END IF;
                      WS_INITIN := 'BEGIN';
                      WS_TMP_CONDICAO := WS_TMP_CONDICAO||WS_CONTEUDO_COMP||',';
                      WS_BINDN := WS_BINDN + 1;
                  ELSE
                      IF  WS_INITIN = 'BEGIN' THEN
                          WS_TMP_CONDICAO := WS_TMP_CONDICAO||WS_CONTEUDO_COMP||',';
                          WS_TMP_CONDICAO := SUBSTR(WS_TMP_CONDICAO,1,LENGTH(WS_TMP_CONDICAO)-1);
                          WS_HAVING := WS_HAVING||WS_CD_COLUNA_ANT||FCL.FPDATA(WS_CONDICAO_ANT,'IGUAL',' IN ',' NOT IN ')||'('||WS_TMP_CONDICAO||') '||WS_LIGACAO_ANT||CRLF;
                          WS_TMP_CONDICAO := '';
                          WS_INITIN := 'NOINIT';
                      ELSE
                          WS_HAVING := WS_HAVING||WS_TMP_CONDICAO;
                          WS_TMP_CONDICAO := '';
                          IF  WS_FILTRO_A.LIGACAO <> WS_LIGACAO_ANT THEN
                              WS_TMP_CONDICAO := WS_TMP_CONDICAO||WS_CD_COLUNA_ANT||WS_TCONDICAO||WS_CONTEUDO_COMP||' ) '||WS_LIGACAO_ANT||' ( '||CRLF;
                          ELSE
                              WS_TMP_CONDICAO := WS_TMP_CONDICAO||WS_CD_COLUNA_ANT||WS_TCONDICAO||WS_CONTEUDO_COMP||' '||WS_LIGACAO_ANT||' '||CRLF;
                          END IF;
                      END IF;
                      WS_BINDN := WS_BINDN + 1;
                  END IF;
              END IF;

              WS_CD_COLUNA_ANT := WS_FILTRO_A.CD_COLUNA;
              WS_CONDICAO_ANT  := WS_FILTRO_A.CONDICAO;
              WS_INDICE_ANT    := WS_FILTRO_A.INDICE;
              WS_LIGACAO_ANT   := WS_FILTRO_A.LIGACAO;
              WS_CONTEUDO_ANT  := WS_FILTRO_A.CONTEUDO;

              CASE WS_CONDICAO_ANT
                  WHEN 'IGUAL'        THEN WS_TCONDICAO := '=';
                  WHEN 'DIFERENTE'    THEN WS_TCONDICAO := '<>';
                  WHEN 'MAIOR'        THEN WS_TCONDICAO := '>';
                  WHEN 'MENOR'        THEN WS_TCONDICAO := '<';
                  WHEN 'MAIOROUIGUAL' THEN WS_TCONDICAO := '>=';
                  WHEN 'MENOROUIGUAL' THEN WS_TCONDICAO := '<=';
                  WHEN 'LIKE'         THEN WS_TCONDICAO := ' like ';
                  WHEN 'NOTLIKE'      THEN WS_TCONDICAO := ' not like ';
                  ELSE                WS_TCONDICAO      := '***';
              END CASE;
    END LOOP;
    CLOSE CRS_FILTRO_A;

    IF  PRM_OBJETO = '%NO_BIND%' THEN
        WS_CONTEUDO_COMP := CHR(39)||WS_CONTEUDO_ANT||CHR(39);
    ELSE
        WS_CONTEUDO_COMP := ' :b'||TRIM(TO_CHAR(WS_BINDN,'00'));
    END IF;

    IF  WS_NOLOOP <> 'NOLOOP' THEN
        IF  WS_INITIN = 'BEGIN' THEN
            WS_TMP_CONDICAO := WS_TMP_CONDICAO||WS_CONTEUDO_COMP||',';
            WS_TMP_CONDICAO := SUBSTR(WS_TMP_CONDICAO,1,LENGTH(WS_TMP_CONDICAO)-1);
            WS_HAVING := WS_HAVING||WS_CD_COLUNA_ANT||FCL.FPDATA(WS_CONDICAO_ANT,'IGUAL',' IN ',' NOT IN ')||'('||WS_TMP_CONDICAO||')'||CRLF;
            WS_BINDN := WS_BINDN + 1;
        ELSE
            WS_TMP_CONDICAO := WS_TMP_CONDICAO||WS_CD_COLUNA_ANT||WS_TCONDICAO||WS_CONTEUDO_COMP||CRLF;
            WS_HAVING := WS_HAVING||WS_TMP_CONDICAO;
            WS_BINDN := WS_BINDN + 1;
        END IF;
    END IF;

    IF  SUBSTR(WS_HAVING,LENGTH(WS_HAVING)-3, 3) ='( (' THEN
        WS_HAVING := SUBSTR(WS_HAVING,1,LENGTH(WS_HAVING)-10)||CRLF;
    ELSE
        WS_HAVING := WS_HAVING||' ) ) ';
    END IF;

    WS_GRUPO := SUBSTR(WS_GRUPO,1,LENGTH(WS_GRUPO)-1);


    IF  PRM_RP IN ('ROLL','GROUP')  THEN
        BEGIN 
            IF  PRM_RP = 'ROLL' THEN
                IF  NVL(TRIM(WS_GORD_R),'SEM') = 'SEM' THEN
                    WS_ORDEM := 'order by '||WS_GORDER||NVL(PRM_ORDEM, '1');
                ELSE
                    WS_ORDEM := 'order by '||WS_GORDER||NVL(PRM_ORDEM, '1')||', '||WS_GORD_R||NVL(PRM_ORDEM, '1');
                END IF;
            ELSE
                WS_ORDEM := 'order by '||NVL(PRM_ORDEM, '1');
            END IF;
        EXCEPTION WHEN OTHERS THEN
            WS_ORDEM := 'order by 1';
        END;
    ELSE
        WS_ORDEM := '';
    END IF;

    IF  PRM_RP = 'SUMARY' THEN
        WS_GRUPO  := '';
        WS_ENDGRP := '';
    ELSE
        WS_ENDGRP := ') ';
    END IF;

    IF  PRM_RP = 'PIZZA' THEN
        WS_ENDGRP := '';
        WS_ORDEM  := 'order by '||PRM_COLUNA;
        WS_GRUPO  := 'group by '||PRM_COLUNA;
    END IF;

    WS_TOP_N := TO_NUMBER(NVL(FUN.GETPROP(PRM_OBJETO,'AMOSTRA'), 0));


    IF  PRM_ORDEM = 'Y' THEN
        WS_ENDGRP := '';
        BEGIN
            BEGIN
                SELECT PROPRIEDADE INTO WS_ORDEM_USER FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_OBJETO AND CD_PROP = 'ORDEM' AND OWNER = WS_USUARIO;
                WS_ORDEM  := 'order by '||WS_ORDEM_USER;
            EXCEPTION WHEN OTHERS THEN
	            WS_ORDEM  := 'order by '||FUN.GETPROP(PRM_OBJETO,'ORDEM', PRM_USUARIO => 'DWU');
            END;
        EXCEPTION WHEN OTHERS THEN
            WS_ORDEM  := 'order by 1';
        END;

        WS_GRUPO  := 'group by '||WS_COLUNA_PRINCIPAL;
    END IF;

    IF  SUBSTR(WS_HAVING,1,1) ='h' AND SUBSTR(WS_HAVING,1,6) <> 'having' THEN
        WS_HAVING := '';
    END IF;

    IF  WS_HAVING='having ( ( ' THEN
        WS_HAVING := '';
    END IF;
	
    PRM_QUERY_PADRAO(1) := 'select '||WS_DISTINTOS||CRLF;
    
    PRM_QUERY_PADRAO(WS_LQUERY) := SUBSTR(PRM_QUERY_PADRAO(WS_LQUERY),1,LENGTH(PRM_QUERY_PADRAO(WS_LQUERY))-3)||CRLF;
    

    WS_LQUERY := WS_LQUERY + 1;

    IF  NVL(TRIM(WS_PAR_FUNCTION),'no_par') <> 'no_par' THEN
        PRM_QUERY_PADRAO(WS_LQUERY) := 'from table('||WS_OPTTABLE||'('||WS_PAR_FUNCTION||')) '||CRLF||WS_CONDICOES||WS_GRUPO||WS_ENDGRP||WS_ORDEM||CRLF;
    ELSE
        IF LENGTH(WS_FILTRO_GERAL) > 0 THEN
		    PRM_QUERY_PADRAO(WS_LQUERY) := 'from (select * from '||WS_OPTTABLE||' where '||WS_FILTRO_GERAL||') '||CRLF||WS_CONDICOES||WS_GRUPO||WS_ENDGRP||WS_HAVING||WS_ORDEM||CRLF;
        ELSE
		    PRM_QUERY_PADRAO(WS_LQUERY) := 'from '||WS_OPTTABLE||' '||CRLF||WS_CONDICOES||WS_GRUPO||WS_ENDGRP||WS_HAVING||WS_ORDEM||CRLF;
		END IF;
        
	END IF;

    PRM_LINHAS := WS_LQUERY;

    IF  WS_CALCULADAS > 0 THEN
        WS_LQUERY := 0;
        BEGIN
             WS_COUNTER := 1;
             LOOP
                 IF  WS_COUNTER > PRM_QUERY_PADRAO.COUNT THEN
                     EXIT;
                 END IF;
                 WS_PRM_QUERY_PADRAO(WS_COUNTER) := PRM_QUERY_PADRAO(WS_COUNTER);
                 WS_COUNTER := WS_COUNTER + 1;

             END LOOP;
        END;

        WS_LQUERY := WS_LQUERY + 1;
        PRM_QUERY_PADRAO(WS_LQUERY) :='with TABELA_X as (';

        BEGIN
             WS_COUNTER := 1;
             LOOP
                 IF  WS_COUNTER > WS_PRM_QUERY_PADRAO.COUNT THEN
                     EXIT;
                 END IF;

                 WS_LQUERY := WS_LQUERY + 1;
                 PRM_QUERY_PADRAO(WS_LQUERY) := WS_PRM_QUERY_PADRAO(WS_COUNTER);
                 WS_COUNTER := WS_COUNTER + 1;
             END LOOP;
        END;

        WS_LQUERY := WS_LQUERY + 1;
        PRM_QUERY_PADRAO(WS_LQUERY) := ') select * from ( select ';

        WS_VIRGULA := '';
        BEGIN
            WS_COUNTER := 0;
            LOOP
                IF  WS_COUNTER > (WS_NM_LABEL.COUNT-1) THEN
                    EXIT;
                END IF;
                WS_COUNTER := WS_COUNTER + 1;
                WS_LQUERY  := WS_LQUERY  + 1;
                PRM_QUERY_PADRAO(WS_LQUERY) := WS_VIRGULA||' '||WS_NM_LABEL(WS_COUNTER);
                WS_VIRGULA := ',';
            END LOOP;

            WS_COUNTER := WS_COUNTER + 1;
            WS_LQUERY  := WS_LQUERY  + 1;
            PRM_QUERY_PADRAO(WS_LQUERY) := WS_VIRGULA||' UP_GRP_ID';
            WS_COUNTER := WS_COUNTER + 1;
            WS_LQUERY  := WS_LQUERY  + 1;
            PRM_QUERY_PADRAO(WS_LQUERY) := WS_VIRGULA||' UP_PRINCI';

        END;

        WS_LQUERY := WS_LQUERY + 1;
        PRM_QUERY_PADRAO(WS_LQUERY) := ' from TABELA_X ';

        WS_VIRGULA := '';
        OPEN CRS_LCALC;
        LOOP
            FETCH CRS_LCALC INTO WS_LCALC;
                  EXIT WHEN CRS_LCALC%NOTFOUND;

                  WS_LQUERY := WS_LQUERY + 1;
                  PRM_QUERY_PADRAO(WS_LQUERY) := ' union all SELECT ';

                  WS_COUNTER := 0;
                  WS_IDENTIFICADOR := ' ';
                  LOOP
                      IF  WS_COUNTER > (WS_NM_LABEL.COUNT-1) THEN
                          EXIT;
                      END IF;

                      WS_COUNTER := WS_COUNTER + 1;
                      IF  WS_TP_LABEL(WS_COUNTER)='1' AND WS_NM_ORIGINAL(WS_COUNTER) = WS_LCALC.CD_COLUNA THEN
                          WS_IDENTIFICADOR := WS_NM_LABEL(WS_COUNTER);
                      END IF;
                  END LOOP;

                  WS_COUNTER := 0;
                  WS_VIRGULA := ' ';
                  LOOP
                      IF  WS_COUNTER > (WS_NM_LABEL.COUNT-1) THEN
                          EXIT;
                      END IF;

                      WS_COUNTER := WS_COUNTER + 1;
                      WS_LQUERY  := WS_LQUERY  + 1;

    	              CASE WS_TP_LABEL(WS_COUNTER)
                                              WHEN '1' THEN
                                                            IF  WS_NM_ORIGINAL(WS_COUNTER) = WS_LCALC.CD_COLUNA THEN
                                                                IF WS_NM_LABEL.COUNT > 1 THEN
                                                                    PRM_QUERY_PADRAO(WS_LQUERY) :=  WS_VIRGULA||CHR(39)||WS_LCALC.CD_COLUNA_SHOW||CHR(39);
                                                                ELSE
                                                                    PRM_QUERY_PADRAO(WS_LQUERY) :=  WS_VIRGULA||CHR(39)||WS_LCALC.DS_COLUNA_SHOW||CHR(39);
                                                                END IF;
                                                            ELSE
                                                                PRM_QUERY_PADRAO(WS_LQUERY) := WS_VIRGULA||CHR(39)||'['||WS_NM_ORIGINAL(WS_CT_LABEL)||']=['||WS_LCALC.CD_COLUNA||']'||CHR(39);
                                                            END IF;
                                              WHEN '2' THEN
                                                            IF  WS_NM_ORIGINAL(WS_COUNTER) = WS_LCALC.CD_COLUNA THEN
                                                                PRM_QUERY_PADRAO(WS_LQUERY) := WS_VIRGULA||CHR(39)||WS_LCALC.DS_COLUNA_SHOW||CHR(39);
                                                            ELSE
                                                                PRM_QUERY_PADRAO(WS_LQUERY) := WS_VIRGULA||CHR(39)||'['||WS_NM_ORIGINAL(WS_CT_LABEL)||']=['||WS_LCALC.CD_COLUNA||']'||CHR(39);
                                                           END IF;
                                              WHEN '3' THEN
                                                           PRM_QUERY_PADRAO(WS_LQUERY) := WS_VIRGULA||'sum('||FUN.GL_CALCULADA(WS_LCALC.DS_FORMULA,WS_IDENTIFICADOR,WS_NM_LABEL(WS_COUNTER), PRM_MICRO_VISAO)||')';
                                              ELSE
                                                           PRM_QUERY_PADRAO(WS_LQUERY) := WS_VIRGULA||CHR(39)||'.'||CHR(39);
                    END CASE;
                    WS_VIRGULA := ',';
                  END LOOP;

                  WS_COUNTER := WS_COUNTER + 1;
                  WS_LQUERY  := WS_LQUERY  + 1;
                  PRM_QUERY_PADRAO(WS_LQUERY) := WS_VIRGULA||' 0 as UP_GRP_ID';
                  WS_COUNTER := WS_COUNTER + 1;
                  WS_LQUERY  := WS_LQUERY  + 1;
                  PRM_QUERY_PADRAO(WS_LQUERY) := WS_VIRGULA||' 0 as UP_PRINCI';

                  WS_LQUERY := WS_LQUERY + 1;
                  PRM_QUERY_PADRAO(WS_LQUERY) := ' from TABELA_X';
	    END LOOP;
        CLOSE CRS_LCALC;
        
        PRM_QUERY_PADRAO(WS_LQUERY) := PRM_QUERY_PADRAO(WS_LQUERY)||' ) order by 1';

            
    END IF;

    PRM_LINHAS := WS_LQUERY;

    
    IF  PRM_CROSS = 'S' THEN
        WS_LQUERY := 0;
        BEGIN
             WS_COUNTER := 1;
             LOOP
                 IF  WS_COUNTER > PRM_QUERY_PADRAO.COUNT THEN
                     EXIT;
                 END IF;
                 WS_PRM_QUERY_PADRAO(WS_COUNTER) := PRM_QUERY_PADRAO(WS_COUNTER);
                 WS_COUNTER := WS_COUNTER + 1;

             END LOOP;
        END;


        WS_LQUERY := WS_LQUERY + 1;
        PRM_QUERY_PADRAO(WS_LQUERY) :='select * from ( WITH TABELA_BASE AS ( ';

        BEGIN
             WS_COUNTER := 1;
             LOOP
                 IF  WS_COUNTER > WS_PRM_QUERY_PADRAO.COUNT THEN
                     EXIT;
                 END IF;

                 WS_LQUERY := WS_LQUERY + 1;
                 PRM_QUERY_PADRAO(WS_LQUERY) := WS_PRM_QUERY_PADRAO(WS_COUNTER);

                 

                 WS_COUNTER := WS_COUNTER + 1;
             END LOOP;
        END;

        
        WS_LQUERY := WS_LQUERY + 1;
        PRM_QUERY_PADRAO(WS_LQUERY) := ' )  select * from ( ';

        WS_UNIONALL := '';
        WS_VCOUNT := 0;
        LOOP
            WS_VCOUNT := WS_VCOUNT + 1;
            IF  WS_VCOUNT > WS_AGRUPADORES.COUNT THEN
                EXIT;
            END IF;

            WS_LQUERY := WS_LQUERY + 1;

            PRM_QUERY_PADRAO(WS_LQUERY) := WS_UNIONALL||'SELECT R_'||PRM_COLUNA||' AS R_'||PRM_COLUNA||', '||CHR(39)||TO_CHAR(WS_VCOUNT,'000')||'-'||WS_AGRUPADORES(WS_VCOUNT)||CHR(39)||' AS '||PRM_COLUNA||', R_'||WS_AGRUPADORES(WS_VCOUNT)||'     AS R_VALOR FROM TABELA_BASE ';

            WS_UNIONALL := ' UNION ALL ';
        END LOOP;
        WS_CURSOR := 'select distinct '||PRM_COLUNA||' from '||WS_OPTTABLE||' '||WS_CONDICOES||' order by '||PRM_COLUNA;

        
        
        WS_PCURSOR := DBMS_SQL.OPEN_CURSOR;



        DBMS_SQL.PARSE(WS_PCURSOR, WS_CURSOR, DBMS_SQL.NATIVE);
        DBMS_SQL.DEFINE_COLUMN(WS_PCURSOR, 1, RET_LCROSS, 400);
        WS_NULO := CORE.BIND_DIRECT(PRM_CONDICOES, WS_PCURSOR, '', PRM_OBJETO, PRM_MICRO_VISAO, PRM_SCREEN);
        WS_LINHAS := DBMS_SQL.EXECUTE(WS_PCURSOR);
        WS_LQUERY := WS_LQUERY + 1;
        PRM_QUERY_PADRAO(WS_LQUERY) := ' )) pivot ( sum(R_VALOR) for R_'||PRM_COLUNA||' in ( ';

        PRM_CAB_CROSS := PRM_COLUNA;
        PRM_NCOLUMNS(1) := PRM_COLUNA;
        WS_VCOUNT       := 1;
        WS_VIRGULA := '';
        
    

        LOOP
            WS_LINHAS := DBMS_SQL.FETCH_ROWS(WS_PCURSOR);
            IF  WS_LINHAS = 1 THEN
                WS_VAZIO := FALSE;
            ELSE
                IF  WS_VAZIO = TRUE THEN
                    DBMS_SQL.CLOSE_CURSOR(WS_PCURSOR);
                    RAISE WS_NODATA;
                END IF;
                EXIT;
            END IF;

            DBMS_SQL.COLUMN_VALUE(WS_PCURSOR, 1, RET_LCROSS);
            WS_LQUERY                   := WS_LQUERY + 1;
            WS_VCOUNT                   := WS_VCOUNT + 1;
            PRM_QUERY_PADRAO(WS_LQUERY) := WS_VIRGULA||CHR(39)||RET_LCROSS||CHR(39);
            BEGIN
                PRM_CAB_CROSS               := PRM_CAB_CROSS||'|'||RET_LCROSS;
            EXCEPTION WHEN OTHERS THEN
                INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, 'Erro de cross', WS_USUARIO, 'ERRO');
                COMMIT;
                EXIT;
            END;
            PRM_NCOLUMNS(WS_VCOUNT)     := RET_LCROSS;

            WS_VIRGULA := ',';
        END LOOP;
        WS_LQUERY := WS_LQUERY + 1;
        PRM_QUERY_PADRAO(WS_LQUERY) := ')) order by 1';
        PRM_LINHAS := WS_LQUERY;
        DBMS_SQL.CLOSE_CURSOR(WS_PCURSOR);
    END IF;
   
    RETURN ('X');
    
EXCEPTION 
    WHEN WS_NODATA THEN
        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, 'Sem dados! - MONTA', WS_USUARIO, 'ERRO');
        COMMIT;
        RETURN 'Sem Dados';
    WHEN WS_NOUSER THEN
        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, 'Sem permiss&atilde;o! - MONTA', WS_USUARIO, 'ERRO');
        COMMIT;
    WHEN OTHERS THEN
        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - MONTA', WS_USUARIO, 'ERRO');
        COMMIT;
END MONTA_QUERY_DIRECT;

FUNCTION BIND_DIRECT (	PRM_CONDICOES	 VARCHAR2	DEFAULT NULL,
						PRM_CURSOR  	 NUMBER     DEFAULT 0,
						PRM_TIPO		 VARCHAR2	DEFAULT NULL,
						PRM_OBJETO		 VARCHAR2	DEFAULT NULL,
						PRM_MICRO_VISAO	 VARCHAR2	DEFAULT NULL,
						PRM_SCREEN       VARCHAR2   DEFAULT NULL,
                        PRM_NO_HAVING    VARCHAR2   DEFAULT 'S' ) RETURN VARCHAR2 AS

	CURSOR CRS_FILTROG ( P_CONDICOES VARCHAR2,
	                     P_VPAR      VARCHAR2,
                         PRM_USUARIO VARCHAR2 ) IS

	                SELECT DISTINCT * FROM ( 
					               SELECT
					                      'DWU' AS CD_USUARIO,
                                          TRIM(PRM_MICRO_VISAO)                 AS MICRO_VISAO,
                                          TRIM(CD_COLUNA)                       AS CD_COLUNA,
                                          'DIFERENTE'                           AS CONDICAO,
                                          REPLACE(TRIM(CONTEUDO), '$[NOT]', '') AS CONTEUDO,
                                          'and'                                 AS LIGACAO,
                                          'float_filter_item'                   AS TIPO
                                   FROM   FLOAT_FILTER_ITEM
                                   WHERE
                                        TRIM(CD_USUARIO) = PRM_USUARIO AND
                                        TRIM(SCREEN) = TRIM(PRM_SCREEN) AND
										INSTR(TRIM(CONTEUDO), '$[NOT]') <> 0 AND
                                        TRIM(CD_COLUNA) NOT IN (SELECT CD_COLUNA FROM FILTROS WHERE CONDICAO = 'NOFLOAT' AND TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND TRIM(CD_OBJETO) = TRIM(PRM_OBJETO) AND TP_FILTRO = 'objeto') AND
                                        TRIM(CD_COLUNA) IN ( SELECT TRIM(CD_COLUNA)
                                                               FROM   MICRO_COLUNA MC
                                                               WHERE  TRIM(MC.CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO) AND
															   TRIM(MC.CD_COLUNA) NOT IN (SELECT DISTINCT NVL(TRIM(CD_COLUNA), 'N/A') FROM TABLE(FUN.VPIPE_PAR(P_CONDICOES)))
															 ) AND FUN.GETPROP(PRM_OBJETO,'FILTRO_FLOAT') = 'N'
								   
								   UNION ALL
								   
								   SELECT
					                      'DWU' AS CD_USUARIO,
                                          TRIM(PRM_MICRO_VISAO) AS MICRO_VISAO,
                                          TRIM(CD_COLUNA)       AS CD_COLUNA,
                                          'IGUAL'               AS CONDICAO,
                                          TRIM(CONTEUDO)     AS CONTEUDO,
                                          'and'                 AS LIGACAO,
                                          'float_filter_item'   AS TIPO
                                   FROM   FLOAT_FILTER_ITEM
                                   WHERE
                                        TRIM(CD_USUARIO) = PRM_USUARIO AND
                                        TRIM(SCREEN) = TRIM(PRM_SCREEN) AND
										INSTR(TRIM(CONTEUDO), '$[NOT]') = 0 AND
                                        TRIM(CD_COLUNA) NOT IN (SELECT CD_COLUNA FROM FILTROS WHERE CONDICAO = 'NOFLOAT' AND TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND TRIM(CD_OBJETO) = TRIM(PRM_OBJETO) AND TP_FILTRO = 'objeto') AND
                                        TRIM(CD_COLUNA) IN ( SELECT TRIM(CD_COLUNA)
                                                               FROM   MICRO_COLUNA MC
                                                               WHERE  TRIM(MC.CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO) AND
															   TRIM(MC.CD_COLUNA) NOT IN (SELECT DISTINCT NVL(TRIM(CD_COLUNA), 'N/A') FROM TABLE(FUN.VPIPE_PAR(P_CONDICOES)))
															 ) AND FUN.GETPROP(PRM_OBJETO,'FILTRO_FLOAT') = 'N'
								UNION ALL
	                SELECT 'DWU'                 AS CD_USUARIO,
	                       TRIM(PRM_MICRO_VISAO) AS MICRO_VISAO,
	                       TRIM(CD_COLUNA)       AS CD_COLUNA,
	                       CD_CONDICAO               AS CONDICAO,
	                       TRIM(CD_CONTEUDO)     AS CONTEUDO,
	                       'and'                 AS LIGACAO,
                           'condicoes'           AS TIPO
	                       FROM TABLE(FUN.VPIPE_PAR(P_CONDICOES)) PC WHERE CD_COLUNA <> '1' AND 
						   (
                           (TRIM(CD_COLUNA) IN (
                               SELECT TRIM(CD_COLUNA) FROM MICRO_COLUNA WHERE TRIM(CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO) AND

                         
						   
						   TRIM(CD_COLUNA)||TRIM(CD_CONTEUDO) NOT IN (
								SELECT NOF.CD_COLUNA||NOF.CONTEUDO FROM  FILTROS NOF
								WHERE  TRIM(NOF.MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND 
								TRIM(NOF.CONDICAO) = 'NOFILTER' AND 
								TRIM(NOF.CONTEUDO) = TRIM(PC.CD_CONTEUDO) AND 
								TRIM(NOF.CD_OBJETO) = TRIM(PRM_OBJETO)
						   )
                                
						   UNION ALL
							 SELECT TRIM(CD_COLUNA) FROM MICRO_VISAO_FPAR WHERE  TRIM(CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO))
							 AND FUN.GETPROP(PRM_OBJETO,'FILTRO_DRILL') = 'N'
                           ) OR PRM_OBJETO LIKE ('COBJ%') ) AND
                           TRIM(CD_COLUNA)||TRIM(CD_CONTEUDO) NOT IN (
								SELECT NOF.CD_COLUNA||NOF.CONTEUDO FROM  FILTROS NOF
								WHERE  TRIM(NOF.MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND 
								TRIM(NOF.CONDICAO) = 'NOFILTER' AND 
								TRIM(NOF.CONTEUDO) = TRIM(PC.CD_CONTEUDO) AND 
								TRIM(NOF.CD_OBJETO) = TRIM(PRM_OBJETO)
						   )
                        UNION ALL

			SELECT	TRIM(CD_USUARIO)	AS CD_USUARIO,
				RTRIM(MICRO_VISAO)	AS MICRO_VISAO,
				RTRIM(CD_COLUNA)	AS CD_COLUNA,
				RTRIM(CONDICAO)		AS CONDICAO,
				RTRIM(CONTEUDO)		AS CONTEUDO,
				RTRIM(LIGACAO)		AS LIGACAO,
                'filtros_objeto'    AS TIPO
			FROM 	FILTROS
			WHERE	TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND 
            ST_AGRUPADO='N' AND 
            CONDICAO <> 'NOFLOAT' AND
			CONDICAO <> 'NOFILTER' AND
            (
                RTRIM(CD_OBJETO) = TRIM(PRM_OBJETO) OR
                (
                    RTRIM(CD_OBJETO) = TRIM(PRM_SCREEN) AND 
                    NVL(FUN.GETPROP(TRIM(PRM_OBJETO),'FILTRO'), 'N/A') <> 'ISOLADO' AND 
                    NVL(FUN.GETPROP(TRIM(PRM_OBJETO),'FILTRO'), 'N/A') <> 'COM CORTE' AND 
                    FUN.GETPROP(PRM_OBJETO,'FILTRO_TELA') <> 'S' 
                )
			)
			AND TP_FILTRO = 'objeto'
            AND TRIM(CD_USUARIO)  = 'DWU'
			
		) WHERE NOT (TRIM(CONDICAO)='IGUAL' AND TRIM(CD_COLUNA) IN (SELECT TRIM(CD_COLUNA) FROM TABLE(FUN.VPIPE_PAR(P_VPAR))))
               ORDER   BY TIPO, CD_USUARIO, MICRO_VISAO, CD_COLUNA, CONDICAO, CONTEUDO;

	WS_FILTROG	CRS_FILTROG%ROWTYPE;

	CURSOR CRS_FILTROGF ( P_CONDICOES VARCHAR2,
	                      P_VPAR      VARCHAR2,
                          PRM_USUARIO VARCHAR2 ) IS
                  SELECT * FROM (
	                SELECT DISTINCT  *
   	                                   FROM (
	                SELECT 'DWU'                 AS CD_USUARIO,
	                       TRIM(PRM_MICRO_VISAO) AS MICRO_VISAO,
	                       TRIM(CD_COLUNA)       AS CD_COLUNA,
	                       CD_CONDICAO               AS CONDICAO,
	                       TRIM(CD_CONTEUDO)     AS CONTEUDO,
	                       'and'                 AS LIGACAO
	                       FROM TABLE(FUN.VPIPE_PAR(P_CONDICOES)) WHERE CD_COLUNA <> '1' AND TRIM(CD_COLUNA) IN (SELECT TRIM(CD_COLUNA) FROM MICRO_COLUNA     WHERE TRIM(CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO) UNION ALL
	                                                                                                         SELECT TRIM(CD_COLUNA) FROM MICRO_VISAO_FPAR WHERE  TRIM(CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO))
                        UNION ALL
			SELECT	TRIM(CD_USUARIO)	AS CD_USUARIO,
				RTRIM(MICRO_VISAO)	AS MICRO_VISAO,
				RTRIM(CD_COLUNA)	AS CD_COLUNA,
				RTRIM(CONDICAO)		AS CONDICAO,
				RTRIM(CONTEUDO)		AS CONTEUDO,
				RTRIM(LIGACAO)		AS LIGACAO
			FROM 	FILTROS T1
			WHERE	RTRIM(MICRO_VISAO) = RTRIM(PRM_MICRO_VISAO) AND
			    TP_FILTRO = 'geral' AND
				(RTRIM(CD_USUARIO)  IN (PRM_USUARIO, 'DWU') OR TRIM(CD_USUARIO) IN (SELECT CD_GROUP FROM GUSERS_ITENS WHERE CD_USUARIO = PRM_USUARIO))
			UNION
			SELECT	TRIM(CD_USUARIO)	AS CD_USUARIO,
				RTRIM(MICRO_VISAO)	AS MICRO_VISAO,
				RTRIM(CD_COLUNA)	AS CD_COLUNA,
				RTRIM(CONDICAO)		AS CONDICAO,
				RTRIM(CONTEUDO)		AS CONTEUDO,
				RTRIM(LIGACAO)		AS LIGACAO
			FROM 	FILTROS
			WHERE	TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND 
			TP_FILTRO = 'objeto' AND 
            CONDICAO <> 'NOFLOAT' AND
            (
             TRIM(CD_OBJETO) = TRIM(PRM_OBJETO) OR
            (TRIM(CD_OBJETO) = TRIM(PRM_SCREEN) AND FUN.GETPROP(TRIM(PRM_OBJETO),'FILTRO')<>'ISOLADO')
            ) AND
				TRIM(CD_USUARIO)  = 'DWU')
                                WHERE   (TRIM(CONDICAO)='IGUAL' AND TRIM(CD_COLUNA) IN (SELECT TRIM(CD_COLUNA) FROM TABLE(FUN.VPIPE_PAR(P_VPAR))))
) WHERE
                            NOT (TRIM(CD_COLUNA) NOT IN (SELECT DISTINCT CD_COLUNA FROM MICRO_VISAO_FPAR WHERE CD_MICRO_VISAO = PRM_MICRO_VISAO) AND FUN.GETPROP(PRM_OBJETO,'FILTRO')='ISOLADO')
				ORDER   BY CD_COLUNA;

	WS_FILTROGF	CRS_FILTROGF%ROWTYPE;

CURSOR CRS_FILTRO_A ( P_CONDICOES    VARCHAR2,
                      P_VPAR         VARCHAR2,
                      PRM_USUARIO    VARCHAR2 ) IS

                        SELECT DISTINCT * FROM (
                                  SELECT 'C'                     AS INDICE,
                                         RTRIM(CD_USUARIO)       AS CD_USUARIO,
                                         RTRIM(MICRO_VISAO)      AS MICRO_VISAO,
                                         RTRIM(CD_COLUNA)        AS CD_COLUNA,
                                         RTRIM(CONDICAO)         AS CONDICAO,
                                         RTRIM(CONTEUDO)         AS CONTEUDO,
                                         RTRIM(LIGACAO)          AS LIGACAO
                                  FROM   FILTROS T1
                                  WHERE  RTRIM(MICRO_VISAO) = RTRIM(PRM_MICRO_VISAO) AND
                                         TP_FILTRO = 'geral' AND
                                         (RTRIM(CD_USUARIO) IN (PRM_USUARIO, 'DWU') OR TRIM(CD_USUARIO) IN (SELECT CD_GROUP FROM GUSERS_ITENS WHERE CD_USUARIO = PRM_USUARIO)) AND
                                         ST_AGRUPADO='S'
                        UNION ALL
                                  SELECT 'C'                     AS INDICE,
                                         RTRIM(CD_USUARIO)       AS CD_USUARIO,
                                         RTRIM(MICRO_VISAO)      AS MICRO_VISAO,
                                         RTRIM(CD_COLUNA)        AS CD_COLUNA,
                                         RTRIM(CONDICAO)         AS CONDICAO,
                                         RTRIM(CONTEUDO)         AS CONTEUDO,
                                         RTRIM(LIGACAO)          AS LIGACAO
                                  FROM   FILTROS
                                  WHERE  TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND ST_AGRUPADO='S' AND
                                         TP_FILTRO = 'objeto' AND
                                         TRIM(CD_OBJETO)   IN (TRIM(PRM_OBJETO), TRIM(PRM_SCREEN)) AND
                                         CONDICAO <> 'NOFLOAT' AND
                                         TRIM(CD_USUARIO)  = 'DWU')
                        WHERE   NOT ( TRIM(CONDICAO)='IGUAL' AND TRIM(CD_COLUNA) IN (SELECT TRIM(CD_COLUNA) FROM TABLE(FUN.VPIPE_PAR(P_VPAR))))
                        ORDER   BY CD_USUARIO, MICRO_VISAO, CD_COLUNA, CONDICAO, CONTEUDO;

   WS_FILTRO_A	CRS_FILTRO_A%ROWTYPE;

	CURSOR CRS_FPAR IS
                        SELECT
                        CD_MICRO_VISAO,
                        CD_COLUNA,
                        CD_PARAMETRO
                        FROM   MICRO_VISAO_FPAR
                        WHERE
	                       CD_MICRO_VISAO = PRM_MICRO_VISAO
	                ORDER BY CD_COLUNA;

	WS_FPAR		CRS_FPAR%ROWTYPE;

	WS_PAR_FUNCTION  VARCHAR2(3000);
    WS_PIPE                 CHAR(1);
	WS_BINDN		NUMBER;
	WS_DISTINTOS	VARCHAR2(8000);
	WS_TEXTO		VARCHAR2(8000);
	WS_TEXTOT		VARCHAR2(8000);
	WS_NM_VAR		VARCHAR2(8000);
	WS_CT_VAR		VARCHAR2(8000);
	WS_NULL			VARCHAR2(8000);
	WS_TCONT		VARCHAR2(200);

	WS_CURSOR	INTEGER;
	WS_LINHAS	INTEGER;

	WS_CALCULADO	VARCHAR2(2000);
	WS_SQL		    VARCHAR2(2000);

	CRLF VARCHAR2( 2 ):= CHR( 13 ) || CHR( 10 );

    WS_NULO VARCHAR2(1) := NULL;
	
	WS_BINDS VARCHAR2(3000);

    WS_USUARIO VARCHAR2(80);

BEGIN

    WS_USUARIO := GBL.GETUSUARIO;

	WS_BINDN := 1;
	
	WS_TEXTO := REPLACE(PRM_CONDICOES, '||', '|');

    IF INSTR(WS_TEXTO, '|', -1) = LENGTH(WS_TEXTO) THEN
      WS_TEXTO := SUBSTR(WS_TEXTO, 0, INSTR(WS_TEXTO, '|', -1)-1);
    END IF;

	IF  PRM_TIPO = 'SUMARY' THEN
	    WS_NULL  := SUBSTR(WS_TEXTO, 1 ,INSTR(WS_TEXTO,'|')-1);
	    WS_TEXTO := REPLACE(WS_TEXTO, WS_NULL||'|', '');
	END IF;

        WS_PAR_FUNCTION := '';
        WS_PIPE := '';

    OPEN CRS_FPAR;
	    LOOP
            FETCH CRS_FPAR INTO WS_FPAR;
            EXIT WHEN CRS_FPAR%NOTFOUND;

            WS_PAR_FUNCTION := WS_PAR_FUNCTION||WS_PIPE||WS_FPAR.CD_COLUNA||'|'||WS_FPAR.CD_PARAMETRO;
            WS_PIPE         := '|';

        END LOOP;
    CLOSE CRS_FPAR;


	OPEN CRS_FILTROG(WS_TEXTO, WS_PAR_FUNCTION, WS_USUARIO);
        LOOP
            FETCH CRS_FILTROG INTO WS_FILTROG;
            EXIT WHEN CRS_FILTROG%NOTFOUND;

            WS_TCONT := WS_FILTROG.CONTEUDO;

            IF  UPPER(SUBSTR(WS_TCONT,1,5)) = 'EXEC=' THEN
                WS_TCONT := FUN.XEXEC(WS_TCONT, PRM_SCREEN);
            END IF;

            IF  UPPER(SUBSTR(WS_TCONT,1,8)) = 'SUBEXEC=' THEN
                WS_TCONT := FUN.XEXEC(FUN.SUBPAR(WS_TCONT, PRM_SCREEN, 'N'), PRM_SCREEN);
            END IF;

            IF  SUBSTR(WS_TCONT,1,2) = '$[' THEN
                WS_TCONT := FUN.GPARAMETRO(WS_TCONT);
            END IF;

            IF  SUBSTR(WS_TCONT,1,2) = '#[' THEN
                WS_TCONT := FUN.RET_VAR(WS_TCONT, WS_USUARIO);
            END IF;

            IF  SUBSTR(WS_TCONT,1,2) = '@[' THEN
                WS_TCONT := FUN.GVALOR(WS_TCONT, PRM_SCREEN);
            END IF;

            WS_BINDS := WS_BINDS||'|'||WS_TCONT;

            DBMS_SQL.BIND_VARIABLE(PRM_CURSOR, ':b'||LTRIM(TO_CHAR(WS_BINDN,'00')), WS_TCONT);

            WS_BINDN := WS_BINDN + 1;

        END LOOP;
	CLOSE CRS_FILTROG;


	OPEN CRS_FILTROGF(WS_TEXTO, WS_PAR_FUNCTION, WS_USUARIO);
	LOOP
	     FETCH CRS_FILTROGF INTO WS_FILTROGF;
		   EXIT WHEN CRS_FILTROGF%NOTFOUND;

	            WS_TCONT := WS_FILTROGF.CONTEUDO;

	            IF UPPER(SUBSTR(WS_TCONT,1,5)) = 'EXEC=' THEN
	                WS_TCONT := FUN.XEXEC(WS_TCONT, PRM_SCREEN);
	            END IF;

                IF UPPER(SUBSTR(WS_TCONT,1,8)) = 'SUBEXEC=' THEN
                    WS_TCONT := FUN.XEXEC(FUN.SUBPAR(WS_TCONT, PRM_SCREEN, 'N'), PRM_SCREEN);
                END IF;
               
                IF  SUBSTR(WS_TCONT,1,2) = '$[' THEN
	                WS_TCONT := FUN.GPARAMETRO(WS_TCONT);
	            END IF;

                IF SUBSTR(WS_TCONT,1,2) = '#[' THEN
	                WS_TCONT := FUN.RET_VAR(WS_TCONT, WS_USUARIO);
	            END IF;

	           
			    WS_BINDS := WS_BINDS||'|'||WS_TCONT;

                DBMS_SQL.BIND_VARIABLE(PRM_CURSOR, ':b'||LTRIM(TO_CHAR(WS_BINDN,'00')), WS_TCONT);
                
	           WS_BINDN := WS_BINDN + 1;

        END LOOP;
        CLOSE CRS_FILTROGF;

	    OPEN CRS_FILTRO_A(WS_TEXTO, WS_PAR_FUNCTION, WS_USUARIO);
	     LOOP
	    FETCH CRS_FILTRO_A INTO WS_FILTRO_A;
		  EXIT WHEN CRS_FILTRO_A%NOTFOUND;

	    WS_TCONT := WS_FILTRO_A.CONTEUDO;

	    IF  SUBSTR(WS_TCONT,1,2) = '$[' THEN
	        WS_TCONT := FUN.GPARAMETRO(WS_TCONT);
	    END IF;

        IF  SUBSTR(WS_TCONT,1,2) = '#[' THEN
	        WS_TCONT := FUN.RET_VAR(WS_TCONT, WS_USUARIO);
	    END IF;

	    IF  UPPER(SUBSTR(WS_TCONT,1,5)) = 'EXEC=' THEN
	        WS_TCONT := FUN.XEXEC(WS_TCONT, PRM_SCREEN);
	    END IF;

         IF  UPPER(SUBSTR(WS_TCONT,1,5)) = 'SUBEXEC=' THEN
	        WS_TCONT := FUN.XEXEC(FUN.SUBPAR(WS_TCONT, PRM_SCREEN, 'N'), PRM_SCREEN);
	    END IF;
		
		WS_BINDS := WS_BINDS||'|'||WS_TCONT;

	    DBMS_SQL.BIND_VARIABLE(PRM_CURSOR, ':b'||LTRIM(TO_CHAR(WS_BINDN,'00')), WS_TCONT);
        
	    WS_BINDN := WS_BINDN + 1;

	    END LOOP;
	    CLOSE CRS_FILTRO_A;
		
  RETURN ('Binds Carregadas='||WS_BINDS);
  
EXCEPTION
	WHEN OTHERS THEN
        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BIND_DIRECT '||PRM_CURSOR, WS_USUARIO, 'ERRO');
        COMMIT;
END BIND_DIRECT;

FUNCTION DATA_DIRECT ( PRM_MICRO_DATA    IN  LONG	     DEFAULT NULL,
			    	   PRM_COLUNA		 IN  LONG	     DEFAULT NULL,
		    		   PRM_QUERY_PADRAO  OUT DBMS_SQL.VARCHAR2A,
			    	   PRM_LINHAS		 OUT NUMBER,
			    	   PRM_NCOLUMNS	     OUT DBMS_SQL.VARCHAR2_TABLE,
			    	   PRM_OBJETO		 IN  VARCHAR2    DEFAULT NULL,
                       PRM_CHAVE		 IN  VARCHAR2    DEFAULT NULL,
		    		   PRM_ORDEM		 IN  VARCHAR2    DEFAULT NULL,
		    		   PRM_SCREEN        IN  VARCHAR2    DEFAULT NULL,
			    	   PRM_LIMITE        IN  NUMBER      DEFAULT NULL,
		    		   PRM_REFERENCIA    IN  NUMBER      DEFAULT 0,
		    		   PRM_DIRECAO       IN  VARCHAR2    DEFAULT '>',
                       PRM_LIMITE_FINAL  OUT NUMBER,
					   PRM_CONDICAO      IN VARCHAR2   DEFAULT 'semelhante',
					   PRM_BUSCA         IN VARCHAR2   DEFAULT NULL,
                       PRM_COUNT         IN BOOLEAN    DEFAULT FALSE,
					   PRM_ACUMULADO     IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

	CURSOR CRS_COLUNAS IS
			SELECT	
            TRIM(CD_COLUNA) 	AS CD_COLUNA,
            TRIM(CD_LIGACAO)	AS CD_LIGACAO,
            TRIM(TIPO)    		AS TIPO,
			TRIM(FORMULA)		AS FORMULA,
            TRIM(TIPO_INPUT)    AS INPUT,
			DATA_TYPE           AS TIPO_COLUMN
			FROM 	DATA_COLUNA, ALL_TAB_COLUMNS
			WHERE	TRIM(CD_MICRO_DATA) = TRIM(PRM_OBJETO) AND
             
            COLUMN_NAME = CD_COLUNA AND
            TABLE_NAME = TRIM(PRM_MICRO_DATA)
            ORDER BY ST_CHAVE DESC, ORDEM ASC, ROWNUM ASC;

	WS_COLUNAS	CRS_COLUNAS%ROWTYPE;

	CURSOR CRS_TABELA IS
			SELECT	NM_TABELA
			FROM 	MICRO_DATA
			WHERE	NM_MICRO_DATA = PRM_OBJETO;

	WS_TABELA	CRS_TABELA%ROWTYPE;

	TYPE GENERIC_CURSOR IS 		REF CURSOR;

	CRS_SAIDA			GENERIC_CURSOR;


    CURSOR CRS_FILTROG(PRM_USUARIO VARCHAR2)  IS
            SELECT
	           RTRIM(CD_USUARIO)	AS CD_USUARIO,
				RTRIM(MICRO_VISAO)	AS MICRO_VISAO,
				RTRIM(CD_COLUNA)	AS CD_COLUNA,
				RTRIM(CONDICAO)		AS CONDICAO,
				RTRIM(CONTEUDO)		AS CONTEUDO,
				RTRIM(LIGACAO)		AS LIGACAO
			FROM 	FILTROS
			WHERE ST_AGRUPADO='N' AND
			TP_FILTRO = 'objeto' AND
            TRIM(CD_OBJETO)   = TRIM(PRM_OBJETO) AND 
            (TRIM(CD_USUARIO)  = PRM_USUARIO OR CD_USUARIO = 'DWU' OR CD_USUARIO IN (SELECT CD_GROUP FROM GUSERS_ITENS WHERE CD_USUARIO = PRM_USUARIO)) AND
            CONDICAO <> 'IGUAL' AND 
            CONDICAO <> 'NOFLOAT'
			ORDER BY CD_USUARIO, MICRO_VISAO, CD_COLUNA, CONDICAO, CONTEUDO;

	WS_FILTROG	CRS_FILTROG%ROWTYPE;

    CURSOR CRS_FILTROGIN(PRM_USUARIO VARCHAR2)  IS
            SELECT
	           RTRIM(CD_USUARIO)	AS CD_USUARIO,
				RTRIM(MICRO_VISAO)	AS MICRO_VISAO,
				RTRIM(CD_COLUNA)	AS CD_COLUNA,
				RTRIM(CONDICAO)		AS CONDICAO,
				RTRIM(CONTEUDO)		AS CONTEUDO,
				RTRIM(LIGACAO)		AS LIGACAO
			FROM 	FILTROS
			WHERE	ST_AGRUPADO='N' AND
			TP_FILTRO = 'objeto' AND
            TRIM(CD_OBJETO) = TRIM(PRM_OBJETO) AND 
            (TRIM(CD_USUARIO)  = PRM_USUARIO OR CD_USUARIO = 'DWU') AND
            CONDICAO = 'IGUAL' AND 
            CONDICAO <> 'NOFLOAT'
			ORDER BY CONDICAO, CD_COLUNA, CD_USUARIO, MICRO_VISAO, CD_COLUNA, CONTEUDO;

	WS_FILTROGIN	CRS_FILTROGIN%ROWTYPE;

	WS_COUNTER       NUMBER := 1;
    WS_FINAL         NUMBER := 0;
    WS_LIMITE        NUMBER := 0;
    WS_COLUNA        NUMBER := 0;
	WS_VIRGULA       CHAR(1);

    WS_LINHA_INICIO  NUMBER;
    WS_LINHA_FINAL   NUMBER;

	WS_CURSOR	     INTEGER;
	WS_LINHAS	     INTEGER;
    WS_RETORNO       VARCHAR2(400);
	WS_SQL		     VARCHAR2(2000);

	WS_DISTINTOS     LONG;
	CRLF             VARCHAR2( 2 ):= CHR( 13 ) || CHR( 10 );
	WS_QUERYOC       VARCHAR2(4000);

    WS_NULO          VARCHAR2(1) := NULL;

    WS_COLUNASF      LONG;
    WS_TCONT		 VARCHAR2(400);
    WS_BINDN         NUMBER;
    WS_CONTEUDO_COMP VARCHAR2(1400);
    WS_CONTEUDO_ANT  VARCHAR2(800);
    WS_CONDICAO      VARCHAR2(800);
    WS_COLUNA_ANT    VARCHAR2(800);
    WS_COUNTIN       NUMBER;
    WS_COUNT         NUMBER;
    WS_CONTEUDO      VARCHAR2(1000);
	WS_TIPO          VARCHAR2(200);
	WS_CHAVE         VARCHAR2(200);
	WS_ACUMULADO     VARCHAR2(1400);
    WS_LIGACAO       VARCHAR2(200);
    WS_BUSCA_DT      DATE;
    WS_BUSCA         VARCHAR2(200);
    WS_USUARIO       VARCHAR2(80);

BEGIN

    WS_USUARIO := GBL.GETUSUARIO;

    HTP.P(WS_NULO);

	WS_DISTINTOS	   := ' ';

	OPEN CRS_TABELA;
	FETCH CRS_TABELA INTO WS_TABELA;
	CLOSE CRS_TABELA;

    

	WS_DISTINTOS := '';
    WS_VIRGULA   := '';

   
    OPEN CRS_COLUNAS;
	LOOP

        FETCH CRS_COLUNAS INTO WS_COLUNAS;
	              EXIT WHEN CRS_COLUNAS%NOTFOUND;

        WS_COLUNA   := WS_COLUNA + 1;
	    IF WS_COLUNAS.INPUT = 'file' THEN
            WS_DISTINTOS := WS_DISTINTOS||WS_VIRGULA||' '''' as '||WS_COLUNAS.CD_COLUNA;
        ELSIF (WS_COLUNAS.INPUT = 'data' OR WS_COLUNAS.INPUT = 'datatime') AND WS_COLUNAS.TIPO_COLUMN = 'DATE' THEN
            

			BEGIN
			    WS_DISTINTOS := WS_DISTINTOS||WS_VIRGULA||' trim(to_char('||WS_COLUNAS.CD_COLUNA||', ''DD/MM/YYYY HH24:MI'')) as '||WS_COLUNAS.CD_COLUNA||'';
            EXCEPTION WHEN OTHERS THEN
			    WS_DISTINTOS := WS_DISTINTOS||WS_VIRGULA||' '||WS_COLUNAS.CD_COLUNA||'';
			END;
		ELSE
		    WS_DISTINTOS := WS_DISTINTOS||WS_VIRGULA||' '||WS_COLUNAS.CD_COLUNA||'';
		END IF;
        PRM_NCOLUMNS(WS_COLUNA) := WS_COLUNAS.CD_COLUNA;
        
	    WS_VIRGULA   := ',';

	END LOOP;
	CLOSE CRS_COLUNAS;

    OPEN CRS_FILTROG(WS_USUARIO);
		LOOP
		    FETCH CRS_FILTROG INTO WS_FILTROG;
			EXIT WHEN CRS_FILTROG%NOTFOUND;

		    WS_TCONT := WS_FILTROG.CONTEUDO;
		    
            IF  UPPER(SUBSTR(WS_TCONT,1,5)) = 'EXEC=' THEN
		        WS_TCONT := FUN.XEXEC(WS_TCONT, PRM_SCREEN);
		    END IF;

            IF  UPPER(SUBSTR(WS_TCONT,1,8)) = 'SUBEXEC=' THEN
                WS_TCONT := FUN.XEXEC(FUN.SUBPAR(WS_TCONT, PRM_SCREEN, 'N'), PRM_SCREEN);
            END IF;
			
		    IF  SUBSTR(WS_TCONT,1,2) = '$[' THEN
		        WS_TCONT := FUN.GPARAMETRO(WS_TCONT);
		    END IF;

            IF  SUBSTR(WS_TCONT,1,2) = '#[' THEN
		        WS_TCONT := FUN.RET_VAR(WS_TCONT, WS_USUARIO);
		    END IF;

            CASE WS_FILTROG.CONDICAO
                WHEN 'IGUAL'        THEN WS_CONDICAO := '=';
                WHEN 'DIFERENTE'    THEN WS_CONDICAO := '<>';
                WHEN 'MAIOR'        THEN WS_CONDICAO := '>';
                WHEN 'MENOR'        THEN WS_CONDICAO := '<';
                WHEN 'MAIOROUIGUAL' THEN WS_CONDICAO := '>=';
                WHEN 'MENOROUIGUAL' THEN WS_CONDICAO := '<=';
                WHEN 'LIKE'         THEN WS_CONDICAO := ' like ';
                WHEN 'NOTLIKE'      THEN WS_CONDICAO := ' not like ';
                ELSE                     WS_CONDICAO := '=';
            END CASE;

            IF WS_FILTROG.CONDICAO IN('LIKE', 'NOTLIKE') THEN
                WS_CONTEUDO_COMP := WS_CONTEUDO_COMP||' '||WS_FILTROG.CD_COLUNA||' '||WS_CONDICAO||' ''%'||WS_TCONT||'%'' AND'; 
            ELSE
                WS_CONTEUDO_COMP := WS_CONTEUDO_COMP||' '||WS_FILTROG.CD_COLUNA||' '||WS_CONDICAO||'  '''||WS_TCONT||''' AND';
            END IF;

		END LOOP;
	CLOSE CRS_FILTROG;
		
	WS_CONTEUDO_COMP := SUBSTR(WS_CONTEUDO_COMP, 1, LENGTH(WS_CONTEUDO_COMP)-3);

    WS_CONTEUDO_ANT := '';
    WS_COUNTIN := 0;
        
    OPEN CRS_FILTROGIN(WS_USUARIO);
	    LOOP
		    FETCH CRS_FILTROGIN INTO WS_FILTROGIN;
			EXIT WHEN CRS_FILTROGIN%NOTFOUND;

		    
            WS_TCONT := WS_FILTROGIN.CONTEUDO;
		    
            IF  UPPER(SUBSTR(WS_TCONT,1,5)) = 'EXEC=' THEN
		        WS_TCONT := FUN.XEXEC(WS_TCONT, PRM_SCREEN);
		    END IF;

            IF  UPPER(SUBSTR(WS_TCONT,1,8)) = 'SUBEXEC=' THEN
                WS_TCONT := FUN.XEXEC(FUN.SUBPAR(WS_TCONT, PRM_SCREEN, 'N'), PRM_SCREEN);
            END IF;
			
		    IF  SUBSTR(WS_TCONT,1,2) = '$[' THEN
		        WS_TCONT := FUN.GPARAMETRO(WS_TCONT);
		    END IF;

            IF  SUBSTR(WS_TCONT,1,2) = '#[' THEN
		        WS_TCONT := FUN.RET_VAR(WS_TCONT, WS_USUARIO);
		    END IF;        

            IF WS_COUNTIN = 0 THEN
                WS_CONTEUDO_ANT := ' '||WS_FILTROGIN.CD_COLUNA||' in ('''||WS_TCONT||''' ';
                WS_COLUNA_ANT := WS_FILTROGIN.CD_COLUNA;
            ELSIF WS_FILTROGIN.CD_COLUNA = WS_COLUNA_ANT THEN
                WS_CONTEUDO_ANT := WS_CONTEUDO_ANT||', '''||WS_TCONT||''' ';
            ELSE
                WS_CONTEUDO_ANT := WS_CONTEUDO_ANT||') and '||WS_FILTROGIN.CD_COLUNA||' in ('''||WS_TCONT||''' ';
                WS_COLUNA_ANT := WS_FILTROGIN.CD_COLUNA;
            END IF;

            WS_COUNTIN := WS_COUNTIN+1;

		END LOOP;
	CLOSE CRS_FILTROGIN;

    IF LENGTH(WS_CONTEUDO_ANT) > 3 THEN
        IF LENGTH(WS_CONTEUDO_COMP) > 3 THEN
            WS_CONTEUDO_COMP := WS_CONTEUDO_COMP||' and '||WS_CONTEUDO_ANT||')';
        ELSE
            WS_CONTEUDO_COMP := WS_CONTEUDO_ANT||')';
        END IF;
    END IF;


    WS_COLUNASF := WS_DISTINTOS||', DWU_ROWID, DWU_ROWNUM ';

    WS_DISTINTOS := WS_DISTINTOS||', ROWID AS DWU_ROWID ';
  
    WS_COLUNA   := WS_COLUNA + 1;
    PRM_NCOLUMNS(WS_COLUNA) := 'DWU_ROWID';
    WS_COLUNA   := WS_COLUNA + 1;
    PRM_NCOLUMNS(WS_COLUNA) := 'DWU_ROWNUM';

    IF PRM_COUNT = TRUE THEN
        PRM_QUERY_PADRAO(1) := 'select count(*) as contador '||CRLF;
    ELSE
	    PRM_QUERY_PADRAO(1) := 'select * from (select a.*, ROWNUM AS DWU_ROWNUM from ( select /*+ FIRST_ROWS('||NVL(PRM_LIMITE, FUN.GETPROP(PRM_OBJETO, 'LINHAS', 'DEFAULT', WS_USUARIO))||') */ '||WS_DISTINTOS||CRLF;
	END IF;

    PRM_QUERY_PADRAO(2) := 'FROM '||WS_TABELA.NM_TABELA||CRLF||' WHERE ';
	
	
	FOR I IN(SELECT CD_COLUNA, CD_CONTEUDO, CD_CONDICAO FROM TABLE((FUN.VPIPE_PAR(PRM_ACUMULADO))) ) LOOP

        SELECT CD_LIGACAO INTO WS_LIGACAO FROM DATA_COLUNA WHERE CD_COLUNA = I.CD_COLUNA AND CD_MICRO_DATA = TRIM(PRM_OBJETO);
	    
		IF I.CD_CONDICAO = 'IGUAL' THEN
		    WS_ACUMULADO := WS_ACUMULADO||'(upper('||TRIM(I.CD_COLUNA)||') = '''||UPPER(TRIM(I.CD_CONTEUDO))||''' or upper('||TRIM(I.CD_COLUNA)||') = '''||FUN.CDESC(UPPER(TRIM(I.CD_CONTEUDO)), WS_LIGACAO, TRUE)||''') and '||CRLF;
        ELSIF I.CD_CONDICAO = 'MAIOR' THEN 
            WS_ACUMULADO := WS_ACUMULADO||'(upper('||TRIM(I.CD_COLUNA)||') >= '''||UPPER(TRIM(I.CD_CONTEUDO))||''' or upper('||TRIM(I.CD_COLUNA)||') >= '''||FUN.CDESC(UPPER(TRIM(I.CD_CONTEUDO)), WS_LIGACAO, TRUE)||''') and '||CRLF;
		ELSIF I.CD_CONDICAO = 'NULO' THEN
            WS_ACUMULADO := WS_ACUMULADO||''||TRIM(I.CD_COLUNA)||' is null and '||CRLF;
        ELSIF I.CD_CONDICAO = 'NNULO' THEN
            WS_ACUMULADO := WS_ACUMULADO||''||TRIM(I.CD_COLUNA)||' is not null and '||CRLF;
		ELSIF I.CD_CONDICAO = 'LIKE' THEN
            WS_ACUMULADO := WS_ACUMULADO||'(upper('||TRIM(I.CD_COLUNA)||') LIKE (''%'||UPPER(TRIM(I.CD_CONTEUDO))||'%'') or upper('||TRIM(I.CD_COLUNA)||') LIKE (''%'||FUN.CDESC(UPPER(TRIM(I.CD_CONTEUDO)), WS_LIGACAO, TRUE)||'%'')) and '||CRLF;
        ELSE
	        WS_ACUMULADO := WS_ACUMULADO||'(upper('||TRIM(I.CD_COLUNA)||') NOT LIKE (''%'||UPPER(TRIM(I.CD_CONTEUDO))||'%'') and upper('||TRIM(I.CD_COLUNA)||') NOT LIKE (''%'||FUN.CDESC(UPPER(TRIM(I.CD_CONTEUDO)), WS_LIGACAO, TRUE)||'%'')) and '||CRLF;
		END IF;
		
	END LOOP;
	
	PRM_QUERY_PADRAO(3) := WS_ACUMULADO;
	
	IF LENGTH(PRM_BUSCA) > 0 THEN
	    IF LENGTH(WS_CONTEUDO_COMP) > 3 THEN
            WS_CONTEUDO_COMP := 'and '||WS_CONTEUDO_COMP;
        END IF;
		
		SELECT DATA_TYPE INTO WS_TIPO FROM ALL_TAB_COLUMNS WHERE  TABLE_NAME = WS_TABELA.NM_TABELA AND COLUMN_NAME = PRM_CHAVE;
		
		IF WS_TIPO = 'DATE' THEN
		    BEGIN
			    WS_CHAVE := PRM_CHAVE;
                WS_BUSCA_DT := TO_DATE(PRM_BUSCA, 'DD/MM/YYYY');
			EXCEPTION WHEN OTHERS THEN
			    WS_CHAVE := '(upper('||TRIM(PRM_CHAVE)||'))';
                WS_BUSCA := UPPER(TRIM(PRM_BUSCA));
			END;

            IF PRM_CONDICAO = 'igual' THEN
                PRM_QUERY_PADRAO(4) := '('||WS_CHAVE||' = '''||WS_BUSCA_DT||''' or '||WS_CHAVE||' = '''||FUN.CDESC(WS_BUSCA_DT, WS_LIGACAO, TRUE)||''') '||WS_CONTEUDO_COMP||' '||CRLF;
            ELSIF PRM_CONDICAO = 'maior' THEN 
                PRM_QUERY_PADRAO(4) := '('||WS_CHAVE||' >= '''||WS_BUSCA_DT||''' or '||WS_CHAVE||' >= '''||FUN.CDESC(WS_BUSCA_DT, WS_LIGACAO, TRUE)||''') '||WS_CONTEUDO_COMP||' '||CRLF;
            ELSIF PRM_CONDICAO = 'nulo' THEN
                PRM_QUERY_PADRAO(4) := WS_CHAVE||' is null '||WS_CONTEUDO_COMP||' '||CRLF;
            ELSIF PRM_CONDICAO = 'nnulo' THEN
                PRM_QUERY_PADRAO(4) := WS_CHAVE||' is not null '||WS_CONTEUDO_COMP||' '||CRLF;
            ELSIF PRM_CONDICAO = 'semelhante' THEN
                PRM_QUERY_PADRAO(4) := '('||WS_CHAVE||' LIKE (''%'||WS_BUSCA_DT||'%'') or '||WS_CHAVE||' LIKE (''%'||FUN.CDESC(WS_BUSCA_DT, WS_LIGACAO, TRUE)||'%'')) '||WS_CONTEUDO_COMP||' '||CRLF;
            ELSE
                PRM_QUERY_PADRAO(4) := '('||WS_CHAVE||' NOT LIKE (''%'||WS_BUSCA_DT||'%'') and '||WS_CHAVE||' NOT LIKE (''%'||FUN.CDESC(WS_BUSCA_DT, WS_LIGACAO, TRUE)||'%'')) '||WS_CONTEUDO_COMP||' '||CRLF;
            END IF;

		ELSIF WS_TIPO = 'NUMBER' THEN

            BEGIN
                WS_CHAVE := PRM_CHAVE;
                WS_BUSCA := TO_NUMBER(PRM_BUSCA);
            EXCEPTION WHEN OTHERS THEN
			    WS_CHAVE := PRM_CHAVE;
                WS_BUSCA := PRM_BUSCA;
			END;

            IF PRM_CONDICAO = 'igual' THEN
                PRM_QUERY_PADRAO(4) := '('||WS_CHAVE||' = '||WS_BUSCA||' or '||WS_CHAVE||' = '''||FUN.CDESC(WS_BUSCA, WS_LIGACAO, TRUE)||''') '||WS_CONTEUDO_COMP||' '||CRLF;
            ELSIF PRM_CONDICAO = 'maior' THEN 
                PRM_QUERY_PADRAO(4) := '('||WS_CHAVE||' >= '||WS_BUSCA||' or '||WS_CHAVE||' >= '''||FUN.CDESC(WS_BUSCA, WS_LIGACAO, TRUE)||''') '||WS_CONTEUDO_COMP||' '||CRLF;
            ELSIF PRM_CONDICAO = 'nulo' THEN
                PRM_QUERY_PADRAO(4) := WS_CHAVE||' is null '||WS_CONTEUDO_COMP||' '||CRLF;
            ELSIF PRM_CONDICAO = 'nnulo' THEN
                PRM_QUERY_PADRAO(4) := WS_CHAVE||' is not null '||WS_CONTEUDO_COMP||' '||CRLF;
            ELSIF PRM_CONDICAO = 'semelhante' THEN
                PRM_QUERY_PADRAO(4) := '('||WS_CHAVE||' LIKE (''%'||WS_BUSCA||'%'') or '||WS_CHAVE||' LIKE (''%'||FUN.CDESC(WS_BUSCA, WS_LIGACAO, TRUE)||'%'')) '||WS_CONTEUDO_COMP||' '||CRLF;
            ELSE
                PRM_QUERY_PADRAO(4) := '('||WS_CHAVE||' NOT LIKE (''%'||WS_BUSCA||'%'') and '||WS_CHAVE||' NOT LIKE (''%'||FUN.CDESC(WS_BUSCA, WS_LIGACAO, TRUE)||'%'')) '||WS_CONTEUDO_COMP||' '||CRLF;
            END IF;

        ELSE
		    WS_CHAVE := '(upper('||TRIM(PRM_CHAVE)||'))';
            WS_BUSCA := UPPER(TRIM(PRM_BUSCA));

            IF PRM_CONDICAO = 'igual' THEN
                PRM_QUERY_PADRAO(4) := '('||WS_CHAVE||' = '''||WS_BUSCA||''' or '||WS_CHAVE||' = '''||FUN.CDESC(WS_BUSCA, WS_LIGACAO, TRUE)||''') '||WS_CONTEUDO_COMP||' '||CRLF;
            ELSIF PRM_CONDICAO = 'maior' THEN 
                PRM_QUERY_PADRAO(4) := '('||WS_CHAVE||' >= '''||WS_BUSCA||''' or '||WS_CHAVE||' >= '''||FUN.CDESC(WS_BUSCA, WS_LIGACAO, TRUE)||''') '||WS_CONTEUDO_COMP||' '||CRLF;
            ELSIF PRM_CONDICAO = 'nulo' THEN
                PRM_QUERY_PADRAO(4) := WS_CHAVE||' is null '||WS_CONTEUDO_COMP||' '||CRLF;
            ELSIF PRM_CONDICAO = 'nnulo' THEN
                PRM_QUERY_PADRAO(4) := WS_CHAVE||' is not null '||WS_CONTEUDO_COMP||' '||CRLF;
            ELSIF PRM_CONDICAO = 'semelhante' THEN
                PRM_QUERY_PADRAO(4) := '('||WS_CHAVE||' LIKE (''%'||WS_BUSCA||'%'') or '||WS_CHAVE||' LIKE (''%'||FUN.CDESC(WS_BUSCA, WS_LIGACAO, TRUE)||'%'')) '||WS_CONTEUDO_COMP||' '||CRLF;
            ELSE
                PRM_QUERY_PADRAO(4) := '('||WS_CHAVE||' NOT LIKE (''%'||WS_BUSCA||'%'') and '||WS_CHAVE||' NOT LIKE (''%'||FUN.CDESC(WS_BUSCA, WS_LIGACAO, TRUE)||'%'')) '||WS_CONTEUDO_COMP||' '||CRLF;
            END IF;


		END IF;

	ELSE
	    IF LENGTH(WS_CONTEUDO_COMP) > 3 THEN
            PRM_QUERY_PADRAO(4) := WS_CONTEUDO_COMP;
        ELSE
            PRM_QUERY_PADRAO(4) := '1=1 ';
        END IF;
	END IF;

    IF PRM_COUNT = TRUE THEN
        PRM_QUERY_PADRAO(5) := ''||CRLF;
    ELSE
        PRM_QUERY_PADRAO(5) := ' ORDER BY '||NVL(FUN.GETPROP(PRM_OBJETO, 'DIRECTION', 'DEFAULT', WS_USUARIO), 1)||CRLF;
    END IF;	

    BEGIN
        WS_SQL := 'select count(*) from '||WS_TABELA.NM_TABELA;
 	    WS_CURSOR := DBMS_SQL.OPEN_CURSOR;
	    DBMS_SQL.PARSE(WS_CURSOR, WS_SQL, DBMS_SQL.NATIVE);
	    DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, 1, WS_RETORNO, 200);
	    WS_LINHAS := DBMS_SQL.EXECUTE(WS_CURSOR);
	    WS_LINHAS := DBMS_SQL.FETCH_ROWS(WS_CURSOR);
	    DBMS_SQL.COLUMN_VALUE(WS_CURSOR, 1, WS_RETORNO);
	    DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
        WS_FINAL         := TO_NUMBER(WS_RETORNO);
        PRM_LIMITE_FINAL := TO_NUMBER(WS_RETORNO);
    EXCEPTION
        WHEN OTHERS THEN 
            WS_FINAL         := 0;
            PRM_LIMITE_FINAL := 0;
    END;

 	CASE
		WHEN PRM_DIRECAO = '>'  THEN 
            WS_LINHA_INICIO := (PRM_REFERENCIA+1);
            WS_LINHA_FINAL  := (PRM_REFERENCIA+PRM_LIMITE);
	 	WHEN PRM_DIRECAO = '>>' THEN 
            WS_LINHA_INICIO := ABS((WS_FINAL-(PRM_LIMITE-1)));
            WS_LINHA_FINAL  := WS_FINAL;
		WHEN PRM_DIRECAO = '<'  THEN
            IF  (PRM_REFERENCIA-PRM_LIMITE) < 1 THEN
                WS_LINHA_INICIO := 1;
                WS_LINHA_FINAL  := (PRM_REFERENCIA-1);
            ELSE
                WS_LINHA_INICIO := ABS((PRM_REFERENCIA-PRM_LIMITE));
                WS_LINHA_FINAL  := (PRM_REFERENCIA-1);
            END IF;
		WHEN PRM_DIRECAO = '<<' THEN 
            WS_LINHA_INICIO := 1;
            WS_LINHA_FINAL  := PRM_LIMITE;						   
	ELSE 
		WS_LINHA_INICIO := 1;
        WS_LINHA_FINAL  := PRM_LIMITE;
	END CASE;

    IF PRM_COUNT = TRUE THEN
        PRM_QUERY_PADRAO(6) := '';
    ELSE
	    PRM_QUERY_PADRAO(6) := ' ) a where rownum <= '||WS_LINHA_FINAL||' ) where DWU_ROWNUM >= '||WS_LINHA_INICIO||' order by '||NVL(FUN.GETPROP(PRM_OBJETO, 'DIRECTION', 'DEFAULT', WS_USUARIO), 1);
	END IF;
    
    PRM_LINHAS := 6;
    WS_COUNT := 0;

	RETURN ('X');

EXCEPTION
	WHEN OTHERS THEN
        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BIND_DIRECT ', WS_USUARIO, 'ERRO');
        COMMIT;
	    RETURN ('['||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||']');
END DATA_DIRECT;

END CORE;
