set define off
create or replace package body FUN  is

FUNCTION RET_LIST (	PRM_CONDICOES VARCHAR2 DEFAULT NULL,
					PRM_LISTA	OUT	DBMS_SQL.VARCHAR2_TABLE ) RETURN VARCHAR2 AS

	WS_BINDN		NUMBER;
	WS_TEXTO		LONG;
	WS_NM_VAR		LONG;
	WS_FLAG			CHAR(1);

BEGIN

	WS_FLAG  := 'N';
	WS_BINDN := 0;
	WS_TEXTO := PRM_CONDICOES;

	LOOP
	    IF  WS_FLAG = 'Y' THEN
	        EXIT;
	    END IF;

	    IF  NVL(INSTR(WS_TEXTO,'|'),0) = 0 THEN
		  WS_FLAG  := 'Y';
		  WS_NM_VAR := WS_TEXTO;
	    ELSE
		  WS_NM_VAR := SUBSTR(WS_TEXTO, 1 ,INSTR(WS_TEXTO,'|')-1);
		  WS_TEXTO  := SUBSTR(WS_TEXTO, LENGTH(WS_NM_VAR||'|')+1, LENGTH(WS_TEXTO));
	    END IF;

	    WS_BINDN := WS_BINDN + 1;
	    PRM_LISTA(WS_BINDN) := WS_NM_VAR;

	END LOOP;

        RETURN FUN.LANG('Binds Carregadas');

EXCEPTION
	WHEN OTHERS THEN
		HTP.P(SQLERRM||'=RET_LIST');

END RET_LIST;

FUNCTION VPIPE ( PRM_ENTRADA VARCHAR2,
                 PRM_DIVISAO VARCHAR2 DEFAULT '|' ) RETURN CHARRET PIPELINED AS

   WS_BINDN      NUMBER;
   WS_TEXTO      VARCHAR2(12000);
   WS_NM_VAR      VARCHAR2(12000);
   WS_FLAG         CHAR(1);

BEGIN

   WS_FLAG  := 'N';
   WS_BINDN := 0;
   WS_TEXTO := PRM_ENTRADA;

   LOOP
       IF  WS_FLAG = 'Y' THEN
           EXIT;
       END IF;

       IF  NVL(INSTR(WS_TEXTO,PRM_DIVISAO),0) = 0 THEN
      WS_FLAG  := 'Y';
      WS_NM_VAR := WS_TEXTO;
       ELSE
      WS_NM_VAR := SUBSTR(WS_TEXTO, 1 ,INSTR(WS_TEXTO,PRM_DIVISAO)-1);
      WS_TEXTO  := SUBSTR(WS_TEXTO, LENGTH(WS_NM_VAR||PRM_DIVISAO)+1, LENGTH(WS_TEXTO));
       END IF;

       WS_BINDN := WS_BINDN + 1;
       PIPE ROW (WS_NM_VAR);

   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      PIPE ROW(SQLERRM||'=RET_LIST');

END VPIPE;


FUNCTION RET_VAR  ( PRM_VARIAVEL   VARCHAR2 DEFAULT NULL, 
                    PRM_USUARIO    VARCHAR2 DEFAULT 'DWU' ) RETURN VARCHAR2 AS

	CURSOR CRS_VARIAVEIS IS
		SELECT 	CONTEUDO
		FROM	VAR_CONTEUDO
		WHERE	USUARIO = PRM_USUARIO AND
			VARIAVEL = REPLACE(REPLACE(PRM_VARIAVEL, '#[', ''), ']', '');

	WS_VARIAVEIS	CRS_VARIAVEIS%ROWTYPE;

BEGIN
	OPEN  CRS_VARIAVEIS;
	FETCH CRS_VARIAVEIS INTO WS_VARIAVEIS;
	CLOSE CRS_VARIAVEIS;

	RETURN (WS_VARIAVEIS.CONTEUDO);
EXCEPTION WHEN OTHERS THEN
    RETURN '';
END RET_VAR;

FUNCTION GETSESSAO  ( PRM_COD VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2  AS

	WS_VALOR VARCHAR2(80);

BEGIN

    SELECT 	VALOR INTO WS_VALOR
	FROM	BI_SESSAO
	WHERE	COD = PRM_COD AND VALOR IN (SELECT USU_NOME FROM USUARIOS);

	RETURN WS_VALOR;
    
EXCEPTION WHEN OTHERS THEN
    RETURN '';
END GETSESSAO;

PROCEDURE SETSESSAO ( PRM_COD   VARCHAR2 DEFAULT NULL,
                      PRM_VALOR VARCHAR2 DEFAULT NULL,
                      PRM_DATA  DATE     DEFAULT NULL ) AS

    WS_TIPO VARCHAR2(80);

BEGIN

    
    IF NVL(PRM_VALOR, 'N/A') = 'N/A' THEN
        
        IF NVL(PRM_DATA, SYSDATE-10) = SYSDATE-10 THEN
            DELETE FROM BI_SESSAO WHERE COD = PRM_COD;
        ELSE
            DELETE FROM BI_SESSAO WHERE DT_ACESSO <= PRM_DATA;
        END IF;
    ELSE

        

        MERGE INTO BI_SESSAO USING DUAL ON (COD = PRM_COD)
        WHEN NOT MATCHED THEN
            INSERT VALUES (PRM_COD, 'USUARIO', NVL(PRM_DATA, SYSDATE+0.5), PRM_VALOR)
        WHEN MATCHED THEN
            UPDATE SET VALOR = PRM_VALOR;
    END IF;

	COMMIT;

END SETSESSAO;

PROCEDURE SET_VAR  ( PRM_VARIAVEL   VARCHAR2 DEFAULT NULL,
                     PRM_CONTEUDO   VARCHAR2 DEFAULT NULL,
                     PRM_USUARIO    VARCHAR2 DEFAULT 'DWU' ) AS

BEGIN
	
	UPDATE VAR_CONTEUDO SET CONTEUDO = PRM_CONTEUDO
	WHERE UPPER(TRIM(VARIAVEL)) = REPLACE(REPLACE(UPPER(TRIM(PRM_VARIAVEL)), '#[', ''), ']', '') AND
	USUARIO = PRM_USUARIO;
	COMMIT;
	

END SET_VAR;

FUNCTION GVALOR( PRM_OBJETO	VARCHAR2 DEFAULT NULL,
                 PRM_SCREEN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

	WS_CD_MICRO_VISAO	PONTO_AVALIACAO.CD_MICRO_VISAO%TYPE;
	WS_PARAMETROS		PONTO_AVALIACAO.PARAMETROS%TYPE;
    WS_PARAMETRO        VARCHAR2(800);
    WS_OBJ              VARCHAR2(200);
    WS_PONTO            VARCHAR2(80);

BEGIN

    WS_OBJ := TRIM(REPLACE(REPLACE(PRM_OBJETO, '@[', ''), ']', ''));
    
	SELECT CD_MICRO_VISAO, PARAMETROS, CD_PONTO INTO
	       WS_CD_MICRO_VISAO, WS_PARAMETROS, WS_PONTO
	FROM   PONTO_AVALIACAO
	WHERE  CD_PONTO = WS_OBJ OR CD_PONTO = (SELECT CD_OBJETO FROM OBJETOS WHERE COD = WS_OBJ);

	RETURN(FUN.VALOR_PONTO( WS_PARAMETROS, WS_CD_MICRO_VISAO, WS_PONTO, PRM_SCREEN ) );
EXCEPTION WHEN OTHERS THEN
    HTP.P(SQLERRM||' - '||WS_PARAMETROS||WS_PARAMETRO);
END GVALOR;


FUNCTION CHECK_BLINK ( PRM_OBJETO    VARCHAR2 DEFAULT NULL,
                       PRM_COLUNA    VARCHAR2 DEFAULT NULL,
                       PRM_CONTEUDO  VARCHAR2 DEFAULT NULL,
                       PRM_ORIGINAL  VARCHAR2 DEFAULT NULL,
                       PRM_SCREEN    VARCHAR2 DEFAULT NULL,
                       PRM_USUARIO   VARCHAR2 DEFAULT NULL ) RETURN CHAR IS
	
    CURSOR CRS_BLINKS IS
		SELECT  CONDICAO, FUN.CONVERT_PAR(CONTEUDO, PRM_SCREEN => PRM_SCREEN) AS CONTEUDO, COR_FUNDO, COR_FONTE, NVL(PRIORIDADE, 0)
		FROM	DESTAQUE T1
		WHERE	(CD_USUARIO = PRM_USUARIO OR CD_USUARIO = 'DWU' OR UPPER(TRIM(CD_USUARIO)) IN (SELECT CD_GROUP FROM GUSERS_ITENS WHERE CD_USUARIO = PRM_USUARIO)) AND
		        CD_OBJETO   = PRM_OBJETO AND
		        CD_COLUNA   = PRM_COLUNA AND
				TIPO_DESTAQUE = 'normal'
				ORDER BY PRIORIDADE ASC;

	WS_BLINK 	CRS_BLINKS%ROWTYPE;

    WS_COR_FUNDO     VARCHAR2(40);
    WS_COR_FONTE     VARCHAR2(40);
    WS_SAIDA         VARCHAR2(2000);
    WS_SAIDA_1        VARCHAR2(2000);

    WS_BLINK_COUNT   NUMBER;
    
    WS_CONTEUDO      NUMBER;
    WS_VALOR         NUMBER;
    WS_CONTEUDO_CHAR VARCHAR2(200);
    WS_VALOR_CHAR    VARCHAR2(200);
    WS_TIPO          VARCHAR2(80);
    WS_USUARIO       VARCHAR2(80);
    WS_NULO          VARCHAR2(1) := NULL;

BEGIN

	WS_SAIDA := PRM_ORIGINAL;
	
	SELECT COUNT(*) INTO WS_BLINK_COUNT
	FROM	DESTAQUE T1
	WHERE	(TRIM(CD_USUARIO) = TRIM(PRM_USUARIO) OR TRIM(CD_USUARIO) = 'DWU' OR UPPER(TRIM(CD_USUARIO)) IN (SELECT CD_GROUP FROM GUSERS_ITENS WHERE CD_USUARIO = WS_USUARIO)) AND
			CD_OBJETO   = PRM_OBJETO AND
			CD_COLUNA   = PRM_COLUNA AND
			TIPO_DESTAQUE  = 'normal';

	IF WS_BLINK_COUNT > 0 THEN
	
		--WS_COR_FUNDO := 'NOBLINK';
		WS_COR_FONTE := 'NOBLINK';
		
		OPEN CRS_BLINKS;
			LOOP
                FETCH CRS_BLINKS INTO WS_BLINK;
                EXIT WHEN CRS_BLINKS%NOTFOUND;

                IF FUN.ISNUMBER(PRM_CONTEUDO) THEN
                    WS_CONTEUDO := TO_NUMBER(WS_BLINK.CONTEUDO);
                    WS_VALOR    := TO_NUMBER(PRM_CONTEUDO);

                    FUN.BLINK_CONDITION(WS_BLINK.CONDICAO, WS_VALOR, WS_CONTEUDO, WS_BLINK.COR_FUNDO, WS_BLINK.COR_FONTE, WS_SAIDA_1, WS_COR_FUNDO, WS_COR_FONTE, PRM_ORIGINAL => WS_SAIDA);

				ELSE
                    WS_CONTEUDO_CHAR := WS_BLINK.CONTEUDO;
                    WS_VALOR_CHAR    := PRM_CONTEUDO;

                    FUN.BLINK_CONDITION(WS_BLINK.CONDICAO, WS_VALOR_CHAR, WS_CONTEUDO_CHAR, WS_BLINK.COR_FUNDO, WS_BLINK.COR_FONTE, WS_SAIDA_1, WS_COR_FUNDO, WS_COR_FONTE, PRM_ORIGINAL => WS_SAIDA);

                END IF;
		
				IF WS_COR_FONTE <> 'NOBLINK' THEN 
					SELECT TP_OBJETO INTO WS_TIPO FROM OBJETOS WHERE CD_OBJETO = PRM_OBJETO;
					IF WS_TIPO = 'CONSULTA' THEN
                        if nvl(WS_COR_FUNDO, 'N/A') = 'N/A' then
                            WS_SAIDA := 'style="color:'||WS_COR_FONTE||'; " ';
                        else
					        WS_SAIDA := 'style=" background-color:'||WS_COR_FUNDO||'; color:'||WS_COR_FONTE||'; " ';
                        end if;
					ELSE
                        if nvl(WS_COR_FUNDO, 'N/A') = 'N/A' then
                            WS_SAIDA := 'color:'||WS_COR_FONTE||'; ';
                        else
					        WS_SAIDA := 'background-color:'||WS_COR_FUNDO||' !important; color:'||WS_COR_FONTE||' !important; ';
                        end if;
					END IF;
				END IF;
			
			END LOOP;
		CLOSE CRS_BLINKS;
		
		RETURN(WS_SAIDA);
		
	ELSE 
	    RETURN(WS_NULO);
	END IF;

	EXCEPTION WHEN OTHERS THEN
		RETURN(WS_NULO);
END CHECK_BLINK;

PROCEDURE BLINK_CONDITION ( PRM_CONDICAO  IN  VARCHAR2,
                            PRM_VALOR     IN  VARCHAR2,
                            PRM_CONTEUDO  IN  VARCHAR2,
                            PRM_COR_FUNDO IN  VARCHAR2,
                            PRM_COR_FONTE IN  VARCHAR2,
                            WS_SAIDA      OUT VARCHAR2,
                            WS_COR_FUNDO  OUT VARCHAR2,
                            WS_COR_FONTE  OUT VARCHAR2,
                            PRM_ORIGINAL  IN  VARCHAR2) AS

BEGIN

    CASE PRM_CONDICAO
        WHEN 'IGUAL' THEN
            BEGIN
                IF TO_NUMBER(PRM_VALOR) = TO_NUMBER(PRM_CONTEUDO) THEN
                    WS_COR_FUNDO := PRM_COR_FUNDO;
                    WS_COR_FONTE := PRM_COR_FONTE;
                END IF;
            EXCEPTION WHEN OTHERS THEN
                BEGIN
                    IF CONV_DATA(PRM_VALOR) = CONV_DATA(PRM_CONTEUDO) THEN
                        WS_COR_FUNDO := PRM_COR_FUNDO;
                        WS_COR_FONTE := PRM_COR_FONTE;
                    END IF;
                EXCEPTION WHEN OTHERS THEN
                    IF PRM_VALOR = PRM_CONTEUDO THEN
                        WS_COR_FUNDO := PRM_COR_FUNDO;
                        WS_COR_FONTE := PRM_COR_FONTE;
                    END IF;
                END;    
            END;
        WHEN 'DIFERENTE' THEN
            BEGIN
                IF TO_NUMBER(PRM_VALOR) <> TO_NUMBER(PRM_CONTEUDO) THEN
                    WS_COR_FUNDO := PRM_COR_FUNDO;
                    WS_COR_FONTE := PRM_COR_FONTE;
                END IF;
            EXCEPTION WHEN OTHERS THEN
                BEGIN
                    IF CONV_DATA(PRM_VALOR) <> CONV_DATA(PRM_CONTEUDO) THEN
                        WS_COR_FUNDO := PRM_COR_FUNDO;
                        WS_COR_FONTE := PRM_COR_FONTE;
                    END IF;
                EXCEPTION WHEN OTHERS THEN
                    IF PRM_VALOR <> PRM_CONTEUDO THEN
                        WS_COR_FUNDO := PRM_COR_FUNDO;
                        WS_COR_FONTE := PRM_COR_FONTE;
                    END IF;
                END;    
            END;
        WHEN 'MAIOR' THEN
            BEGIN
                IF TO_NUMBER(PRM_VALOR) > TO_NUMBER(PRM_CONTEUDO) THEN
                    WS_COR_FUNDO := PRM_COR_FUNDO;
                    WS_COR_FONTE := PRM_COR_FONTE;
                END IF;
            EXCEPTION WHEN OTHERS THEN
                BEGIN
                    IF CONV_DATA(PRM_VALOR) > CONV_DATA(PRM_CONTEUDO) THEN
                        WS_COR_FUNDO := PRM_COR_FUNDO;
                        WS_COR_FONTE := PRM_COR_FONTE;
                    END IF;
                EXCEPTION WHEN OTHERS THEN
                    IF PRM_VALOR > PRM_CONTEUDO THEN
                        WS_COR_FUNDO := PRM_COR_FUNDO;
                        WS_COR_FONTE := PRM_COR_FONTE;
                    END IF;
                END;    
            END;
        WHEN 'MENOR' THEN
            BEGIN
                IF TO_NUMBER(PRM_VALOR) < TO_NUMBER(PRM_CONTEUDO) THEN
                    WS_COR_FUNDO := PRM_COR_FUNDO;
                    WS_COR_FONTE := PRM_COR_FONTE;
                END IF;
            EXCEPTION WHEN OTHERS THEN
                BEGIN
                    IF CONV_DATA(PRM_VALOR) < CONV_DATA(PRM_CONTEUDO) THEN
                        WS_COR_FUNDO := PRM_COR_FUNDO;
                        WS_COR_FONTE := PRM_COR_FONTE;
                    END IF;
                EXCEPTION WHEN OTHERS THEN
                    IF PRM_VALOR < PRM_CONTEUDO THEN
                        WS_COR_FUNDO := PRM_COR_FUNDO;
                        WS_COR_FONTE := PRM_COR_FONTE;
                    END IF;
                END;    
            END;
        WHEN 'MAIOROUIGUAL' THEN
            BEGIN
                IF TO_NUMBER(PRM_VALOR) >= TO_NUMBER(PRM_CONTEUDO) THEN
                    WS_COR_FUNDO := PRM_COR_FUNDO;
                    WS_COR_FONTE := PRM_COR_FONTE;
                END IF;
            EXCEPTION WHEN OTHERS THEN
                BEGIN
                    IF CONV_DATA(PRM_VALOR) >= CONV_DATA(PRM_CONTEUDO) THEN
                        WS_COR_FUNDO := PRM_COR_FUNDO;
                        WS_COR_FONTE := PRM_COR_FONTE;
                    END IF;
                EXCEPTION WHEN OTHERS THEN
                    IF PRM_VALOR >= PRM_CONTEUDO THEN
                        WS_COR_FUNDO := PRM_COR_FUNDO;
                        WS_COR_FONTE := PRM_COR_FONTE;
                    END IF;
                END;     
            END;
        WHEN 'MENOROUIGUAL' THEN
             BEGIN
                IF TO_NUMBER(PRM_VALOR) <= TO_NUMBER(PRM_CONTEUDO) THEN
                    WS_COR_FUNDO := PRM_COR_FUNDO;
                    WS_COR_FONTE := PRM_COR_FONTE;
                END IF;
            EXCEPTION WHEN OTHERS THEN
                BEGIN
                    IF CONV_DATA(PRM_VALOR) <= CONV_DATA(PRM_CONTEUDO) THEN
                        WS_COR_FUNDO := PRM_COR_FUNDO;
                        WS_COR_FONTE := PRM_COR_FONTE;
                    END IF;
                EXCEPTION WHEN OTHERS THEN
                    IF PRM_VALOR <= PRM_CONTEUDO THEN
                        WS_COR_FUNDO := PRM_COR_FUNDO;
                        WS_COR_FONTE := PRM_COR_FONTE;
                    END IF;
                END;    
            END;
        WHEN 'LIKE' THEN
            IF  PRM_VALOR LIKE PRM_CONTEUDO THEN
                WS_COR_FUNDO := PRM_COR_FUNDO;
                WS_COR_FONTE := PRM_COR_FONTE;
            END IF;
        WHEN 'NOTLIKE' THEN
            IF  PRM_VALOR NOT LIKE PRM_CONTEUDO THEN
                WS_COR_FUNDO := PRM_COR_FUNDO;
                WS_COR_FONTE := PRM_COR_FONTE;
            END IF;
        ELSE
            WS_SAIDA := PRM_ORIGINAL;
    END CASE;

END BLINK_CONDITION;


FUNCTION CHECK_BLINK_TOTAL ( PRM_OBJETO   VARCHAR2 DEFAULT NULL,
                             PRM_COLUNA   VARCHAR2 DEFAULT NULL,
                             PRM_CONTEUDO VARCHAR2 DEFAULT NULL,
                             PRM_ORIGINAL VARCHAR2 DEFAULT NULL,
                             PRM_SCREEN   VARCHAR2 DEFAULT NULL ) RETURN CHAR IS
	
    CURSOR CRS_BLINKS(PRM_USUARIO VARCHAR2) IS
		SELECT  CONDICAO, FUN.CONVERT_PAR(CONTEUDO, PRM_SCREEN => PRM_SCREEN) AS CONTEUDO, COR_FUNDO, COR_FONTE, PRIORIDADE
		FROM	DESTAQUE
		WHERE	(UPPER(TRIM(CD_USUARIO))  = PRM_USUARIO OR UPPER(TRIM(CD_USUARIO)) = 'DWU' OR UPPER(TRIM(CD_USUARIO)) IN (SELECT CD_GROUP FROM GUSERS_ITENS WHERE CD_USUARIO = PRM_USUARIO)) AND
		        CD_OBJETO   = PRM_OBJETO AND
		        CD_COLUNA   = PRM_COLUNA AND
				(TIPO_DESTAQUE = 'total')
				ORDER BY TIPO_DESTAQUE ASC, PRIORIDADE ASC;

	WS_BLINK 	CRS_BLINKS%ROWTYPE;

        WS_COR_FUNDO    VARCHAR2(40);
        WS_COR_FONTE    VARCHAR2(40);
        WS_USUARIO      VARCHAR2(80);
		WS_SAIDA        VARCHAR2(2000);
        WS_SAIDA_1      VARCHAR2(2000);

        WS_BLINK_COUNT  NUMBER;
		
		WS_CONTEUDO NUMBER;
		WS_VALOR NUMBER;
        WS_NULO  VARCHAR2(1) := NULL;

BEGIN

    WS_USUARIO := GBL.GETUSUARIO;

	WS_SAIDA   := PRM_ORIGINAL;
	
	SELECT COUNT(*) INTO WS_BLINK_COUNT
	FROM	DESTAQUE
	WHERE	(UPPER(TRIM(CD_USUARIO))  = WS_USUARIO OR UPPER(TRIM(CD_USUARIO)) = 'DWU' OR UPPER(TRIM(CD_USUARIO)) IN (SELECT CD_GROUP FROM GUSERS_ITENS WHERE CD_USUARIO = WS_USUARIO)) AND
			CD_OBJETO   = PRM_OBJETO AND
			CD_COLUNA   = PRM_COLUNA AND 
			(TIPO_DESTAQUE  = 'total');

	IF WS_BLINK_COUNT > 0 THEN
	
		OPEN CRS_BLINKS(WS_USUARIO);
			LOOP
			FETCH CRS_BLINKS INTO WS_BLINK;
			EXIT WHEN CRS_BLINKS%NOTFOUND;
		
				BEGIN
					WS_CONTEUDO := TO_NUMBER(WS_BLINK.CONTEUDO);
				EXCEPTION WHEN OTHERS THEN
					WS_CONTEUDO := 0;
				END;
			
				BEGIN
					WS_VALOR := TO_NUMBER(PRM_CONTEUDO);
				EXCEPTION WHEN OTHERS THEN
					WS_VALOR := 0;
				END;
				
				--WS_COR_FUNDO := 'NOBLINK';
				WS_COR_FONTE := 'NOBLINK';

                FUN.BLINK_CONDITION(WS_BLINK.CONDICAO, WS_VALOR, WS_CONTEUDO, WS_BLINK.COR_FUNDO, WS_BLINK.COR_FONTE, WS_SAIDA_1, WS_COR_FUNDO, WS_COR_FONTE, PRM_ORIGINAL => WS_SAIDA);
				if WS_COR_FONTE<>'NOBLINK'THEN	
                   /*IF nvl(WS_COR_FUNDO,'N/A') <> 'N/A' THEN 
                        WS_SAIDA := '<style> table#'||PRM_OBJETO||'c tr.total td, table#'||PRM_OBJETO||'trlc tr.total td { background-color:'||WS_COR_FUNDO||' !important; color:'||WS_COR_FONTE||' !important; }</style>';
                   else
                        WS_SAIDA := '<style> table#'||PRM_OBJETO||'c tr.total td, table#'||PRM_OBJETO||'trlc tr.total td {color:'||WS_COR_FONTE||' !important; }</style>';
                
                    END IF;*/
                    -- Alterado para aplicar somente na celula e não na linha inteira -- ws_saida := '<style> table#'||prm_objeto||'c tr.total.geral td { background-color:'||ws_cor_fundo||' !important; color:'||ws_cor_fonte||' !important; }</style>';
                    IF NVL(WS_COR_FUNDO, 'N/A') = 'N/A' THEN

                       WS_SAIDA := 'STYLE=" COLOR:'||WS_COR_FONTE||' !IMPORTANT; " ';

                    ELSE

                       WS_SAIDA := 'STYLE=" BACKGROUND-COLOR:'||WS_COR_FUNDO||' !IMPORTANT; COLOR:'||WS_COR_FONTE||' !IMPORTANT;" ';
                       
                    END IF;
                end if;
			
			END LOOP;
		CLOSE CRS_BLINKS;
		
		RETURN(WS_SAIDA);
			
	ELSE
	    RETURN(WS_NULO);
	END IF;

EXCEPTION WHEN OTHERS THEN
	RETURN(WS_NULO);
END CHECK_BLINK_TOTAL;


FUNCTION CHECK_BLINK_LINHA ( PRM_OBJETO   VARCHAR2 DEFAULT NULL,
                             PRM_COLUNA   VARCHAR2 DEFAULT NULL,
                             PRM_LINHA    VARCHAR2 DEFAULT NULL,
                             PRM_CONTEUDO VARCHAR2 DEFAULT NULL,
                             PRM_SCREEN   VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 IS
	CURSOR CRS_BLINKS(PRM_USUARIO VARCHAR2) IS
		SELECT  CONDICAO, FUN.CONVERT_PAR(CONTEUDO, PRM_SCREEN => PRM_SCREEN) AS CONTEUDO, COR_FUNDO, COR_FONTE, CD_USUARIO, TIPO_DESTAQUE, PRIORIDADE
		FROM	DESTAQUE
		WHERE	(UPPER(TRIM(CD_USUARIO)) = PRM_USUARIO OR UPPER(TRIM(CD_USUARIO)) = 'DWU' OR UPPER(TRIM(CD_USUARIO)) IN (SELECT CD_GROUP FROM GUSERS_ITENS WHERE CD_USUARIO = PRM_USUARIO)) AND
		        TRIM(CD_OBJETO)   = TRIM(PRM_OBJETO) AND
				(TIPO_DESTAQUE = 'linha' OR TIPO_DESTAQUE = 'estrela') AND
				TRIM(CD_COLUNA) = TRIM(PRM_COLUNA)
				ORDER BY PRIORIDADE ASC;

	WS_BLINK 	CRS_BLINKS%ROWTYPE;
    WS_COR_FUNDO     VARCHAR2(80);
    WS_COR_FONTE     VARCHAR2(80);
	WS_SAIDA         VARCHAR2(4000) := '';
    WS_SAIDA_1       VARCHAR2(4000) := '';
    WS_BLINK_COUNT   NUMBER;	
	WS_CONTEUDO      VARCHAR2(200);
	WS_VALOR         VARCHAR2(200);
	WS_CONTEUDO_N    NUMBER;
	WS_VALOR_N       NUMBER;
    WS_NULO          VARCHAR2(1) := NULL;
    WS_TIPO          VARCHAR2(120);
    WS_TIPO_DESTAQUE VARCHAR2(120);
    WS_USUARIO       VARCHAR2(120);

BEGIN

    WS_USUARIO := GBL.GETUSUARIO;
	
	SELECT COUNT(*) INTO WS_BLINK_COUNT
	FROM	DESTAQUE
	WHERE	(UPPER(TRIM(CD_USUARIO)) = WS_USUARIO OR UPPER(TRIM(CD_USUARIO)) = 'DWU' OR UPPER(TRIM(CD_USUARIO)) IN (SELECT CD_GROUP FROM GUSERS_ITENS WHERE CD_USUARIO = WS_USUARIO)) AND
			TRIM(CD_OBJETO)   = TRIM(PRM_OBJETO) AND
			(TIPO_DESTAQUE = 'linha' OR TIPO_DESTAQUE = 'estrela') AND
			CD_COLUNA = TRIM(PRM_COLUNA);

    WS_COR_FUNDO := 'NOBLINK';
	WS_COR_FONTE := 'NOBLINK';


	IF WS_BLINK_COUNT > 0 THEN
	
		OPEN CRS_BLINKS(WS_USUARIO);
			LOOP
			FETCH CRS_BLINKS INTO WS_BLINK;
			EXIT WHEN CRS_BLINKS%NOTFOUND;
			
			WS_VALOR_N    := 0;
			WS_CONTEUDO_N := 0;
		
			BEGIN
				WS_CONTEUDO := TRIM(WS_BLINK.CONTEUDO);
			EXCEPTION WHEN OTHERS THEN
				WS_CONTEUDO := 0;
			END;
			
			BEGIN
				WS_VALOR := TRIM(PRM_CONTEUDO);
			EXCEPTION WHEN OTHERS THEN
				WS_VALOR := 0;
			END;


			BEGIN
			    
		        WS_VALOR_N    := PRM_CONTEUDO;
		        WS_CONTEUDO_N := WS_BLINK.CONTEUDO;
			    
                FUN.BLINK_CONDITION(WS_BLINK.CONDICAO, WS_VALOR_N, WS_CONTEUDO_N, WS_BLINK.COR_FUNDO, WS_BLINK.COR_FONTE, WS_SAIDA_1, WS_COR_FUNDO, WS_COR_FONTE, WS_SAIDA);
                WS_TIPO_DESTAQUE := WS_BLINK.TIPO_DESTAQUE;
 
			EXCEPTION WHEN OTHERS THEN

                FUN.BLINK_CONDITION(WS_BLINK.CONDICAO, UPPER(WS_VALOR), UPPER(WS_CONTEUDO), WS_BLINK.COR_FUNDO, WS_BLINK.COR_FONTE, WS_SAIDA_1, WS_COR_FUNDO, WS_COR_FONTE, WS_SAIDA);
                WS_TIPO_DESTAQUE := WS_BLINK.TIPO_DESTAQUE;

            END;

            SELECT TP_OBJETO INTO WS_TIPO FROM OBJETOS WHERE TRIM(CD_OBJETO) = TRIM(PRM_OBJETO);
					
            IF WS_TIPO = 'BROWSER' THEN
                IF (UPPER(TRIM(WS_BLINK.CD_USUARIO)) = WS_USUARIO OR UPPER(TRIM(WS_BLINK.CD_USUARIO)) = 'DWU') AND (TRIM(WS_COR_FUNDO) <> 'NOBLINK' AND TRIM(WS_COR_FONTE) <> 'NOBLINK') THEN
	                IF WS_TIPO_DESTAQUE = 'estrela' THEN
	                    WS_SAIDA := WS_SAIDA_1||WS_SAIDA||' <style> tr#'||PRM_LINHA||' td.destaqueicon { background-color:'||WS_COR_FUNDO||' !important; } tr#'||PRM_LINHA||' td.destaqueicon svg { fill:'||WS_COR_FONTE||' !important; }</style>';
	                ELSE
					    WS_SAIDA := WS_SAIDA_1||WS_SAIDA||' <style> tr#'||PRM_LINHA||' td { background-color:'||WS_COR_FUNDO||' !important; color:'||WS_COR_FONTE||' !important; }</style>';
	                END IF;
                END IF;
            ELSE
                IF WS_COR_FUNDO <> 'NOBLINK' AND WS_COR_FONTE <> 'NOBLINK' THEN 
					WS_SAIDA := WS_SAIDA_1||WS_SAIDA||'<td class="print" title="'||WS_VALOR_N||' - '||WS_CONTEUDO_N||' - '||WS_VALOR||' - '||WS_CONTEUDO||'" style="display: none; visibility: hidden;">background:'||WS_COR_FUNDO||'; color:'||WS_COR_FONTE||' !important;</td>';
				END IF;
            END IF;

		END LOOP;
		CLOSE CRS_BLINKS;
		
		RETURN(WS_SAIDA);
			
	ELSE
	    RETURN(WS_NULO);
	END IF;
		
EXCEPTION WHEN OTHERS THEN
	RETURN(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END CHECK_BLINK_LINHA;


FUNCTION WACESSO ( PRM_WHO VARCHAR2 DEFAULT 'ALL') RETURN CHARRET PIPELINED IS
	CURSOR CRS_ROLE IS
		SELECT  CD_ROLE, TIPO
		FROM	ROLES
		WHERE	CD_USUARIO=GBL.GETUSUARIO;

	WS_ROLE		CRS_ROLE%ROWTYPE;

	WS_COUNT	NUMBER;

BEGIN

	SELECT NVL(COUNT(*),0) INTO WS_COUNT
	FROM ROLES
	WHERE CD_USUARIO = GBL.GETUSUARIO AND TIPO='ONLY';

	IF  PRM_WHO='ALL' THEN
	    IF  WS_COUNT = 0 THEN
		OPEN CRS_ROLE;
		LOOP
		   FETCH CRS_ROLE INTO WS_ROLE;
			 EXIT WHEN CRS_ROLE%NOTFOUND;
		   PIPE ROW (WS_ROLE.CD_ROLE);
		END LOOP;
		CLOSE CRS_ROLE;
	    ELSE
		IF  WS_COUNT > 1 THEN
		    PIPE ROW ('ERROR');
		ELSE
		    SELECT MAX(CD_ROLE) INTO WS_ROLE.CD_ROLE
		    FROM ROLES
		    WHERE CD_USUARIO=GBL.GETUSUARIO AND TIPO='ONLY';
		    PIPE ROW (WS_ROLE.CD_ROLE);
		END IF;
	    END IF;
	ELSE
	    SELECT MAX(CD_ROLE) INTO WS_ROLE.CD_ROLE
	    FROM ROLES
	    WHERE CD_USUARIO=GBL.GETUSUARIO AND TIPO='ME';
	    PIPE ROW (WS_ROLE.CD_ROLE);
	END IF;

END WACESSO;


FUNCTION WHO RETURN VARCHAR AS

  WS_SAIDA  VARCHAR2(80);
  WS_NULO   VARCHAR2(1) := NULL;

BEGIN

  SELECT COLUMN_VALUE INTO WS_SAIDA
  FROM TABLE(FUN.WACESSO('ME'));

 RETURN (WS_SAIDA);

EXCEPTION
    WHEN OTHERS THEN
         RETURN(WS_NULO);
END WHO;


FUNCTION GPARAMETRO ( PRM_PARAMETRO VARCHAR2 DEFAULT NULL, 
                      PRM_DESC      VARCHAR2 DEFAULT 'N',
                      PRM_SCREEN    VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

    WS_CONTEUDO VARCHAR2(200);
    WS_SAIDA    VARCHAR2(200);
    WS_DESC     VARCHAR2(200);
    WS_USUARIO  VARCHAR2(80);

    WS_FILTRO   NUMBER;
    WS_NULO     VARCHAR2(1) := NULL;

BEGIN

    WS_USUARIO := GBL.GETUSUARIO;

    WS_CONTEUDO := PRM_PARAMETRO;
    WS_CONTEUDO := REPLACE(WS_CONTEUDO, '$[','');
    WS_CONTEUDO := REPLACE(WS_CONTEUDO, ']', '');

    BEGIN
        SELECT NVL(UPPER(CONTEUDO),' ') INTO WS_SAIDA
        FROM  PARAMETRO_USUARIO
        WHERE
                CD_USUARIO = WS_USUARIO AND
                UPPER(TRIM(CD_PADRAO)) = UPPER(TRIM(WS_CONTEUDO));
    EXCEPTION
         WHEN OTHERS THEN
              BEGIN
                   SELECT NVL(UPPER(CONTEUDO),' ') INTO WS_SAIDA
                   FROM   PARAMETRO_USUARIO
                   WHERE
                          CD_USUARIO = 'DWU' AND
                          UPPER(TRIM(CD_PADRAO)) = UPPER(TRIM(WS_CONTEUDO));
              EXCEPTION
                   WHEN OTHERS THEN WS_SAIDA := '';
              END;
    END;

    SELECT COUNT(*) INTO WS_FILTRO
    FROM   FLOAT_FILTER_ITEM
    WHERE
           CD_USUARIO = WS_USUARIO AND
           CD_COLUNA  = WS_CONTEUDO AND
           SCREEN     = PRM_SCREEN;

    IF  WS_FILTRO = 1 THEN
        BEGIN
             SELECT NVL(MAX(CONTEUDO),' ') INTO WS_SAIDA
             FROM   FLOAT_FILTER_ITEM
             WHERE
                    CD_USUARIO = WS_USUARIO AND
                    CD_COLUNA  = WS_CONTEUDO AND
                    SCREEN     = PRM_SCREEN;
        EXCEPTION
             WHEN OTHERS THEN
                  WS_SAIDA := ' ';
        END;
	END IF;

    IF  PRM_DESC = 'Y' THEN
        BEGIN
            SELECT NVL(CD_LIGACAO,'SEM') INTO WS_DESC
            FROM   PARAMETRO_PADRAO
            WHERE
                   CD_PADRAO=WS_CONTEUDO;
        EXCEPTION
            WHEN OTHERS THEN WS_DESC := 'SEM';
        END;
        IF  WS_DESC <> 'SEM' THEN
            WS_SAIDA := FUN.CDESC(WS_SAIDA,WS_DESC);
        END IF;
    END IF;

    RETURN(WS_SAIDA);

EXCEPTION WHEN OTHERS THEN
    RETURN(SQLERRM);
END GPARAMETRO;

FUNCTION GFORMULA ( prm_texto        varchar2 default null,
                    prm_micro_visao  varchar2 default null,
                    prm_agrupador    varchar2 default null,
                    prm_inicio       varchar2 default 'NO',
                    prm_final        varchar2 default 'NO',
                    prm_screen       varchar2 default null,
                    prm_recurs       varchar2 default null,
                    prm_flexcol      varchar2 default 'N',
                    prm_flexend      varchar2 default 'N' ) return varchar2 as

    ws_texto     varchar2(4000);
    ws_flex_text  varchar2(4000);
    ws_funcao     varchar2(4000);
	ws_var       varchar2(4000);
	ws_agrupador varchar2(20);
	ws_fix_agrupador varchar2(20);
	ws_tipo      varchar2(1);
	ws_calculada    varchar2(1);
	ws_formula    varchar2(4000);
	ws_nm_var   varchar2(4000);
	ws_recurs    varchar2(2);
	ws_flexcol   varchar2(4000);
	ws_flexend   varchar2(4000);

    ws_count number;

    ws_nulo varchar2(1) := null;

begin

    ws_count   := 0;
    ws_texto   := prm_texto;
    ws_funcao  := '';
    ws_recurs  := prm_recurs;
    ws_flexcol := 'N';
    ws_flexend := prm_flexend;


    if rtrim(substr(ws_texto,1,8))='FLEXCOL=' then
        ws_texto := replace(ws_texto,'FLEXCOL=','');
        ws_nm_var := substr(ws_texto, 1 ,instr(ws_texto,'|')-1);
        ws_texto  := substr(ws_texto, length(ws_nm_var||'|')+1, length(ws_texto));

	    begin
            SELECT decode(st_agrupador,'SEM','',st_agrupador) into ws_agrupador
            FROM   MICRO_COLUNA
            where  cd_coluna=fun.gparametro(trim(ws_nm_var), '', prm_screen) and cd_micro_visao=prm_micro_visao;
		exception when others then
            insert into log_eventos values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, user, 'FORMULA', 'ERRORGFORMULA', '01');
        end;

        if prm_agrupador = 'EXT' then
            ws_flex_text := fcl.fpdata(prm_inicio,'NO','',prm_inicio)||replace(ws_texto,'$[FLEXCOL]','??????')||fcl.fpdata(prm_final,'NO','',prm_final);
            ws_flex_text := fun.gformula(ws_flex_text,prm_micro_visao,'EXT','','',prm_screen,'N','N');
            ws_texto := fun.GFORMULA('$['||fun.gparametro(trim(ws_nm_var), prm_screen => prm_screen)||']',prm_micro_visao,'EXT','','',prm_screen,'N','N',ws_flex_text);
        else
            ws_texto  := fcl.fpdata(prm_inicio,'NO','',prm_inicio)||replace(ws_texto,'$[FLEXCOL]',fun.GFORMULA('$['||fun.gparametro(trim(ws_nm_var), prm_screen => prm_screen)||']',prm_micro_visao,ws_agrupador,'','',prm_screen,prm_recurs,'N'))||fcl.fpdata(prm_final,'NO','',prm_final);
        end if;

        ws_funcao := ws_texto;
    else
        ws_texto := upper(ws_texto)||'[END]';

        loop
            ws_count := ws_count + 1;
            if substr(ws_texto,ws_count,5)='[END]' then
                exit;
            end if;

            if substr(ptg_trans(ws_texto),ws_count,1) in (',','_','Q','W','E','R','T','Y','U','I','O','P','A','S','D','F','G','H','J','K','L','Z','X','C','V','B','N','M') then
                ws_funcao := ws_funcao||substr(ws_texto,ws_count,1);
            end if;

            if substr(ws_texto,ws_count,1) in ('+','-','/','*','(',')','>', '<', chr(39), '|', '=', ':') then
                ws_funcao := ws_funcao||substr(ws_texto,ws_count,1);
            end if;

            if substr(ws_texto,ws_count,1) in (' ','?','.','0','1','2','3','4','5','6','7','8','9') then
                ws_funcao := ws_funcao||substr(ws_texto,ws_count,1);
            end if;

            if substr(ws_texto,ws_count,1) in ('$', '@', '&', '#') then
                ws_tipo := substr(ws_texto,ws_count,1);
                ws_var  := '';
                ws_count := ws_count + 1;
                if substr(ws_texto,ws_count,1)<>'[' then
                    return('ERRO');
                else
                    loop
                        ws_count  := ws_count + 1;
                        if substr(ws_texto,ws_count,1)=']' then
                            if ws_tipo = '$' then
                                begin
                                    SELECT decode(st_agrupador,'SEM','',st_agrupador), tipo, formula
                                    into ws_agrupador, ws_calculada, ws_formula
                                    FROM MICRO_COLUNA
                                    where cd_coluna = ws_var and
                                    cd_micro_visao=prm_micro_visao;
                                end;

                                ws_fix_agrupador := ws_agrupador;

                                if ws_recurs = 'S' then
                                    ws_agrupador := 'EXT';
                                end if;

                                if prm_flexcol <> 'N' then
                                    if prm_flexcol not in ('S','Y') then
                                        ws_funcao := ws_funcao||prm_inicio||replace(prm_flexcol,'$[FLEXCOL]','$['||ws_var||']')||prm_final;
                                    else
                                        if prm_flexcol = 'Y' then
                                            ws_funcao := ws_funcao||fun.GFORMULA(ws_formula,prm_micro_visao,ws_agrupador,'','',prm_screen,'N','N',prm_flexend);
                                        else
                                            ws_funcao := ws_funcao||'('||ws_var||')';
                                        end if;
                                    end if;
                                else
                                    if prm_agrupador = 'EXT' then
                                        if prm_inicio = 'NO' and prm_final = 'NO' then
                                            if ws_calculada = 'C' then
                                                ws_funcao := ws_funcao||fcl.fpdata(ws_agrupador,'EXT','',ws_agrupador)||'('||fun.GFORMULA(ws_formula,prm_micro_visao,ws_agrupador,'','',prm_screen,'S',prm_flexcol,prm_flexend)||')';
                                            else
                                                ws_funcao := ws_funcao||fcl.fpdata(ws_agrupador,'EXT','',ws_agrupador)||'('||ws_var||')';
                                            end if;
                                        else
                                            if ws_calculada = 'C' then
                                                ws_funcao := ws_funcao||fcl.fpdata(ws_agrupador,'EXT','',ws_agrupador)||'('||prm_inicio||fun.GFORMULA(ws_formula,prm_micro_visao,ws_agrupador,'','',prm_screen,'S',prm_flexcol,prm_flexend)||prm_final||')';
                                            else
                                                if prm_flexend = 'N' then
                                                    ws_funcao := ws_funcao||fcl.fpdata(ws_agrupador,'EXT','',ws_agrupador)||'('||prm_inicio||ws_var||prm_final||')';
                                                else
                                                    ws_funcao := ws_funcao||ws_fix_agrupador||'('||prm_inicio||replace(ws_flexend,'??????',ws_var)||prm_final||')';
                                                end if;
                                            end if;
                                        end if;
                                    else
                                        if ws_calculada = 'C' then
                                            ws_funcao := ws_funcao||fcl.fpdata(ws_agrupador,'EXT',ws_agrupador,'')||'('||fun.GFORMULA(ws_formula,prm_micro_visao,'EXT','','',prm_screen,'S',prm_flexcol,prm_flexend)||')';
                                        else
                                            ws_funcao := ws_funcao||'('||ws_var||')';
                                        end if;
                                    end if;
                                end if;
                            else
                                if ws_tipo = '&' then
                                    ws_funcao := ws_funcao||chr(39)||fun.gparametro('$['||ws_var||']', prm_screen => prm_screen)||chr(39);
                                else
                                    if ws_tipo = '#' then
                                        ws_funcao := ws_funcao||fun.ret_var(ws_var, 'DWU');
                                    else
                                        ws_funcao := ws_funcao||fun.gvalor(ws_var, prm_screen);
                                    end if;
                                end if;
                            end if;
                            exit;
                        end if;
                        ws_var := ws_var||substr(ws_texto,ws_count,1);
                    end loop;
                end if;
            end if;
        end loop;
    end if;

return(ws_funcao);
exception when others then
htp.p(ws_nulo);

end GFORMULA;

FUNCTION GFORMULA2 ( PRM_MICRO_VISAO  VARCHAR2 DEFAULT NULL,
                     PRM_COLUNA       VARCHAR2 DEFAULT NULL,
                     PRM_SCREEN       VARCHAR2 DEFAULT NULL,
                     PRM_INSIDE       VARCHAR2 DEFAULT 'N',
                     PRM_OBJETO       VARCHAR2 DEFAULT NULL,
                     PRM_INICIO       VARCHAR2 DEFAULT NULL,
                     PRM_FINAL        VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

    WS_FUNCAO    VARCHAR2(4000);
    WS_FORMULA   VARCHAR2(32000);
    WS_FLEXCOL   VARCHAR2(80);
    WS_AGRUPADOR VARCHAR2(80);
    WS_COUNT     NUMBER;
    WS_VARIAVEL  VARCHAR2(32000);
    WS_TIPO      VARCHAR2(20);
    WS_EXIST     NUMBER;
    WS_INSIDE    VARCHAR2(80);
    WS_FLEX      VARCHAR2(1);
    WS_CS_COLUNA VARCHAR2(200);
    WS_VAR       VARCHAR2(800);
    
BEGIN

	

    
    SELECT COUNT(*) INTO WS_EXIST FROM MICRO_COLUNA
	WHERE UPPER(CD_COLUNA) = UPPER(REPLACE(REPLACE(PRM_COLUNA, '$[', ''), ']', '')) 
	AND CD_MICRO_VISAO = PRM_MICRO_VISAO AND TIPO = 'T';
	
	SELECT FORMULA, FLEXCOL, ST_AGRUPADOR INTO WS_FORMULA, WS_FLEXCOL, WS_AGRUPADOR 
	FROM MICRO_COLUNA
	WHERE CD_MICRO_VISAO = PRM_MICRO_VISAO AND UPPER(CD_COLUNA) = UPPER(PRM_COLUNA);
    
    IF WS_EXIST = 0 THEN

	    SELECT REGEXP_COUNT(WS_FORMULA, '.\[[a-zA-Z0-9_]+\]') INTO WS_COUNT FROM DUAL;
	    
	    FOR I IN 1..WS_COUNT LOOP
	        
	        SELECT REGEXP_SUBSTR(WS_FORMULA, '.\[[a-zA-Z0-9_]+\]', 1) INTO WS_VARIAVEL FROM DUAL;
	        
	        SELECT COUNT(*) INTO WS_EXIST FROM MICRO_COLUNA
	        WHERE CD_COLUNA = REPLACE(REPLACE(WS_VARIAVEL, '$[', ''), ']', '') 
	        AND CD_MICRO_VISAO = PRM_MICRO_VISAO AND TIPO = 'T';
	        
	        IF WS_EXIST = 0 THEN
	            
				IF INSTR(WS_VARIAVEL, '$[FLEX_DIM]') > 0 AND NVL(PRM_OBJETO, 'N/A') <> 'N/A' THEN
			        SELECT CS_COLUNA INTO WS_CS_COLUNA FROM PONTO_AVALIACAO WHERE CD_PONTO = PRM_OBJETO;
			        SELECT COLUMN_VALUE INTO WS_CS_COLUNA FROM TABLE((FUN.VPIPE(WS_CS_COLUNA))) WHERE ROWNUM = 1;
			        WS_VARIAVEL := REPLACE(WS_VARIAVEL, '$[FLEX_DIM]', WS_CS_COLUNA);
					WS_TIPO := 'N';
					
			    ELSE
	        
					IF TRIM(UPPER(WS_VARIAVEL)) = '$[FLEXCOL]' THEN
						
						WS_VARIAVEL := '$['||WS_FLEXCOL||']'; 
						
						WS_VARIAVEL := FUN.GPARAMETRO(WS_VARIAVEL, PRM_SCREEN => PRM_SCREEN);
						WS_FLEX := 'S';
						WS_TIPO := 'EXT';
						WS_INSIDE := 'N';
						
						IF WS_FLEX  = 'S' THEN
							SELECT ST_AGRUPADOR INTO WS_AGRUPADOR FROM MICRO_COLUNA WHERE UPPER(TRIM(CD_COLUNA)) = UPPER(TRIM(REPLACE(REPLACE(WS_VARIAVEL, '$[', ''), ']', ''))) AND CD_MICRO_VISAO = PRM_MICRO_VISAO;
						END IF;
						
					ELSE
						
						WS_TIPO := TRIM(SUBSTR(WS_VARIAVEL, 1, 1));
						IF WS_TIPO = '$' THEN
							WS_TIPO := 'EXT';
						END IF;
						WS_INSIDE := WS_AGRUPADOR;
					END IF;
		        END IF;


                CASE WS_TIPO
		            WHEN '$' THEN
		                WS_VARIAVEL := FUN.GPARAMETRO(WS_VARIAVEL, PRM_SCREEN => PRM_SCREEN);
		            WHEN '&' THEN
		                WS_VARIAVEL := CHR(39)||FUN.GPARAMETRO(REPLACE(WS_VARIAVEL, '&', '$'), PRM_SCREEN => PRM_SCREEN)||CHR(39);
		            WHEN '#' THEN
		                WS_VARIAVEL := FUN.RET_VAR(WS_VARIAVEL, GBL.GETUSUARIO);
		            WHEN 'EXT' THEN
                        WS_VARIAVEL := FUN.GFORMULA2(PRM_MICRO_VISAO, REPLACE(REPLACE(WS_VARIAVEL, '$[', ''), ']', ''), PRM_SCREEN, WS_INSIDE, PRM_OBJETO, PRM_INICIO, PRM_FINAL);
		            WHEN 'N' THEN
		                WS_VARIAVEL := WS_VARIAVEL;
                    WHEN '@' THEN
		                WS_VARIAVEL := FUN.GVALOR(WS_VARIAVEL, PRM_SCREEN);
		        ELSE
                    WS_VARIAVEL := WS_VARIAVEL;
		        END CASE;
		        
		    ELSE
		        
                IF PRM_INSIDE  = 'EXT' THEN
                    SELECT ST_AGRUPADOR INTO WS_AGRUPADOR FROM MICRO_COLUNA WHERE UPPER(TRIM(CD_COLUNA)) = UPPER(TRIM(REPLACE(REPLACE(WS_VARIAVEL, '$[', ''), ']', ''))) AND CD_MICRO_VISAO = PRM_MICRO_VISAO;
                END IF;
                    
                WS_VARIAVEL := FUN.GFORMULA2(PRM_MICRO_VISAO, REPLACE(REPLACE(WS_VARIAVEL, '$[', ''), ']', ''), PRM_SCREEN, WS_AGRUPADOR, PRM_OBJETO, PRM_INICIO, PRM_FINAL);

		    END IF;

			SELECT REGEXP_REPLACE(WS_FORMULA, '.\[[a-zA-Z0-9_]+\]', WS_VARIAVEL, 1, 1) INTO WS_FORMULA FROM DUAL;
		    
	    END LOOP;

        WS_FORMULA := REPLACE(REPLACE(WS_FORMULA, CHR(13), ''), CHR(10), ' ');
	    

	    IF WS_FLEX = 'S'  THEN

			IF WS_AGRUPADOR = 'EXT' THEN
		        RETURN '('||WS_FORMULA||')';
		    ELSE
		        IF NVL(PRM_INICIO, 'N/A') <> 'N/A' THEN
					WS_FORMULA := PRM_INICIO||WS_FORMULA||PRM_FINAL;
				END IF;
				
	            IF WS_AGRUPADOR IN ('PSM','PCT','CNT') THEN
					
                    WS_FORMULA := FUN.GFORMULA2(PRM_MICRO_VISAO, REPLACE(REPLACE(WS_FORMULA, '$[', ''), ']', ''), PRM_SCREEN, WS_AGRUPADOR, PRM_OBJETO, PRM_INICIO, PRM_FINAL);
                    
                    IF WS_AGRUPADOR = 'PSM' THEN
						RETURN 'trunc((ratio_to_report(sum('||WS_FORMULA||')) over ()*100))';
					ELSE
						IF WS_AGRUPADOR = 'CNT' THEN
							RETURN 'count(distinct '||WS_FORMULA||')';
						ELSE
							RETURN 'trunc((ratio_to_report(count(distinct '||WS_FORMULA||')) over ()*100))';
						END IF;
					END IF;
				ELSE
					RETURN WS_AGRUPADOR||'('||WS_FORMULA||')';
				END IF;
				
				
	        END IF;
			
	    ELSIF PRM_INSIDE = 'EXT' THEN 
	        
			IF NVL(PRM_INICIO, 'N/A') <> 'N/A' THEN
				WS_FORMULA := PRM_INICIO||WS_FORMULA||PRM_FINAL;
			END IF;
			
	        IF WS_AGRUPADOR = 'EXT' THEN
		        RETURN '('||WS_FORMULA||')';
		    ELSE
		        IF WS_AGRUPADOR <> 'SEM' THEN
		            
	                IF WS_AGRUPADOR IN ('PSM','PCT','CNT') THEN

                        WS_FORMULA := FUN.GFORMULA2(PRM_MICRO_VISAO, REPLACE(REPLACE(WS_FORMULA, '$[', ''), ']', ''), PRM_SCREEN, WS_AGRUPADOR, PRM_OBJETO, PRM_INICIO, PRM_FINAL);

						IF WS_AGRUPADOR = 'PSM' THEN
							RETURN 'trunc((ratio_to_report(sum('||WS_FORMULA||')) over ()*100))';
						ELSE
							IF WS_AGRUPADOR = 'CNT' THEN
								RETURN 'count(distinct '||WS_FORMULA||')';
							ELSE
								RETURN 'trunc((ratio_to_report(count(distinct '||WS_FORMULA||')) over ()*100))';
							END IF;
						END IF;
					ELSE
						RETURN WS_AGRUPADOR||'('||WS_FORMULA||')';
					END IF;
					
	            ELSE
	                RETURN '('||WS_FORMULA||')';
	            END IF;
	        END IF;
	    ELSE
		    IF WS_AGRUPADOR = 'EXT' THEN
		        RETURN WS_FORMULA;
		    ELSE
		        RETURN WS_FORMULA;
		    END IF;
		END IF;
		
	ELSE	
		
        IF PRM_INSIDE = 'EXT' THEN
            IF WS_AGRUPADOR <> 'SEM' AND WS_AGRUPADOR <> 'EXT' THEN
                IF NVL(PRM_INICIO, 'N/A') <> 'N/A' THEN
				    RETURN WS_AGRUPADOR||'('||PRM_INICIO||PRM_COLUNA||PRM_FINAL||')';
				ELSE
                    RETURN WS_AGRUPADOR||'('||PRM_COLUNA||')';
                END IF;
            ELSE
                RETURN '('||PRM_COLUNA||')';
            END IF;
        ELSE
            RETURN PRM_COLUNA;
        END IF;
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, PRM_COLUNA||'|'||PRM_MICRO_VISAO||' == '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' -  '||WS_FLEXCOL||' - GFORMULA', GBL.GETUSUARIO, 'ERRO');
    COMMIT;
END GFORMULA2;


FUNCTION URL_DEFAULT ( PRM_PARAMETROS	IN  LONG,
					   PRM_MICRO_VISAO	IN  LONG,
					   PRM_AGRUPADORES	IN OUT LONG,
					   PRM_COLUNA		IN OUT LONG,
					   PRM_RP		    IN OUT LONG,
					   PRM_COLUP		IN OUT LONG,
					   PRM_COMANDO		IN  LONG,
					   PRM_MODE		    IN OUT LONG ) RETURN VARCHAR2 AS

	WS_URL		LONG;
	WS_COMANDO	LONG;
	WS_COLUNA	LONG;

	WS_PIPE		CHAR;
	WS_TEXTO	LONG;
	WS_TEXTOT	LONG;
	WS_NM_VAR	LONG;
	WS_CTVAR	INTEGER;
	WS_RESTRICT     VARCHAR2(200);

	WS_AGRUPADORES	DBMS_SQL.VARCHAR2_TABLE;
	WS_COLDEF	DBMS_SQL.VARCHAR2_TABLE;
	WS_CUPDEF	DBMS_SQL.VARCHAR2_TABLE;

    WS_NULO VARCHAR2(1) := NULL;

BEGIN

    

	WS_TEXTO  := PRM_AGRUPADORES;
	WS_TEXTOT := WS_TEXTO;
	WS_CTVAR  := 0;

	LOOP
	    IF  WS_TEXTOT = '%END%' OR TRIM(WS_TEXTOT) = ' ' THEN
	        EXIT;
	    END IF;

	    IF  NVL(INSTR(WS_TEXTOT,'|'),0) = 0 THEN
	        WS_NM_VAR := WS_TEXTOT;
	        WS_TEXTOT := '%END%';
	    ELSE
            WS_TEXTO  := '['||WS_TEXTOT||']';
            WS_NM_VAR := SUBSTR('['||WS_TEXTOT||']', 1 ,INSTR(WS_TEXTO,'|')-1);
            WS_TEXTOT := REPLACE(WS_TEXTO, WS_NM_VAR||'|', '');
			
			
			WS_TEXTOT := REPLACE(WS_TEXTOT, '[', '');
			WS_TEXTOT := REPLACE(WS_TEXTOT, ']', '');
			WS_TEXTO  := REPLACE(WS_TEXTO, '[', '');
			WS_TEXTO  := REPLACE(WS_TEXTO, ']', '');
			WS_NM_VAR := REPLACE(WS_NM_VAR, '[', '');
			WS_NM_VAR := REPLACE(WS_NM_VAR, ']', '');
	    END IF;

	    SELECT COUNT(*) INTO WS_RESTRICT
            FROM COLUMN_RESTRICTION RST WHERE RST.USUARIO = GBL.GETUSUARIO AND
                                              RST.CD_MICRO_VISAO = TRIM(PRM_MICRO_VISAO) AND
                                              RST.CD_COLUNA = WS_NM_VAR AND
                                              RST.ST_RESTRICAO = 'I';

            IF  WS_RESTRICT < 1 THEN
		WS_CTVAR := WS_CTVAR + 1;
	        WS_AGRUPADORES(WS_CTVAR) := WS_NM_VAR;
            END IF;

	END LOOP;

    

	WS_TEXTO   := PRM_COLUNA;
	WS_TEXTOT  := WS_TEXTO;
	WS_CTVAR   := 0;

	LOOP
	    IF  WS_TEXTOT = '%END%' OR TRIM(WS_TEXTOT) IS NULL THEN
	        EXIT;
	    END IF;

	    IF  NVL(INSTR(WS_TEXTOT,'|'),0) = 0 THEN
	        WS_NM_VAR := WS_TEXTOT;
	        WS_TEXTOT := '%END%';
	    ELSE
		WS_TEXTO  := WS_TEXTOT;
		WS_NM_VAR := SUBSTR(WS_TEXTOT, 1 ,INSTR(WS_TEXTO,'|')-1);
		WS_TEXTOT := REPLACE(WS_TEXTO, WS_NM_VAR||'|', '');
	    END IF;

	    WS_CTVAR := WS_CTVAR + 1;
	    WS_COLDEF(WS_CTVAR) := WS_NM_VAR;

	END LOOP;

    

	WS_TEXTO  := PRM_COLUP;
	WS_TEXTOT := WS_TEXTO;
	WS_CTVAR  := 0;

	LOOP
	    IF  WS_TEXTOT = '%END%' OR TRIM(WS_TEXTOT) IS NULL THEN
	        EXIT;
	    END IF;

	    IF  NVL(INSTR(WS_TEXTOT,'|'),0) = 0 THEN
	        WS_NM_VAR := WS_TEXTOT;
	        WS_TEXTOT := '%END%';
	    ELSE
		WS_TEXTO  := WS_TEXTOT;
		WS_NM_VAR := SUBSTR(WS_TEXTOT, 1 ,INSTR(WS_TEXTO,'|')-1);
		WS_TEXTOT := REPLACE(WS_TEXTO, WS_NM_VAR||'|', '');
	    END IF;

	    WS_CTVAR := WS_CTVAR + 1;
	    WS_CUPDEF(WS_CTVAR) := WS_NM_VAR;

	END LOOP;


    

	IF  NVL(INSTR(PRM_COMANDO,'|'),0) > 0 THEN
	    WS_COMANDO	:= SUBSTR(PRM_COMANDO, 1 ,INSTR(PRM_COMANDO,'|')-1);
	    WS_COLUNA	:= REPLACE(PRM_COMANDO, WS_COMANDO||'|', '');
	END IF;

	IF  WS_COMANDO = 'COLUP' AND NOT FUN.SETEM(PRM_COLUP,WS_COLUNA) THEN
	    WS_CUPDEF(WS_CUPDEF.COUNT+1) := WS_COLUNA;
	    WS_COMANDO := 'DELCUP';
	END IF;

	IF  WS_COMANDO = 'COLDOWN' AND NOT FUN.SETEM(PRM_COLUNA,WS_COLUNA) THEN
	    WS_COLDEF(WS_COLDEF.COUNT+1) := WS_COLUNA;
	    WS_COMANDO := 'DELCOL';
	END IF;

	IF  WS_COMANDO = 'COLGRP' AND NOT FUN.SETEM(PRM_AGRUPADORES,WS_COLUNA) THEN
	    WS_AGRUPADORES(WS_AGRUPADORES.COUNT+1) := WS_COLUNA;
	END IF;

    

	PRM_AGRUPADORES := '';
	WS_CTVAR  := 0;
	LOOP
	    WS_CTVAR := WS_CTVAR + 1;
	    IF  WS_CTVAR > WS_AGRUPADORES.COUNT THEN
	        EXIT;
	    END IF;

	    IF  WS_COMANDO = 'COLLEFT' AND WS_CTVAR > 1 AND WS_AGRUPADORES.COUNT > 1 AND WS_AGRUPADORES(WS_CTVAR)=WS_COLUNA THEN
	        WS_TEXTO                   := WS_AGRUPADORES(WS_CTVAR-1);
	        WS_AGRUPADORES(WS_CTVAR-1) := WS_AGRUPADORES(WS_CTVAR);
	        WS_AGRUPADORES(WS_CTVAR)   := WS_TEXTO;
	        EXIT;
	    END IF;
	    IF  WS_COMANDO = 'COLRIGHT' AND WS_CTVAR < WS_AGRUPADORES.COUNT AND WS_AGRUPADORES.COUNT > 1 AND WS_AGRUPADORES(WS_CTVAR)=WS_COLUNA THEN
	        WS_TEXTO                   := WS_AGRUPADORES(WS_CTVAR+1);
	        WS_AGRUPADORES(WS_CTVAR+1) := WS_AGRUPADORES(WS_CTVAR);
	        WS_AGRUPADORES(WS_CTVAR)   := WS_TEXTO;
	        EXIT;
	    END IF;
	END LOOP;
	WS_CTVAR	:= 0;
	WS_PIPE		:= '';
	LOOP
	    WS_CTVAR := WS_CTVAR + 1;
	    IF  WS_CTVAR > WS_AGRUPADORES.COUNT THEN
	        EXIT;
	    END IF;
	    IF  WS_COMANDO = 'DELETE' AND WS_AGRUPADORES(WS_CTVAR) = WS_COLUNA THEN
	        WS_COLUNA := WS_COLUNA;
	    ELSE
		PRM_AGRUPADORES := PRM_AGRUPADORES||WS_PIPE||WS_AGRUPADORES(WS_CTVAR);
		WS_PIPE := '|';
	    END IF;
	END LOOP;

    

	PRM_COLUNA := '';
	WS_CTVAR  := 0;
	LOOP
	    WS_CTVAR := WS_CTVAR + 1;
	    IF  WS_CTVAR > WS_COLDEF.COUNT THEN
	        EXIT;
	    END IF;

	    IF  WS_COMANDO = 'COLLEFT' AND WS_CTVAR > 1 AND WS_COLDEF.COUNT > 1 AND WS_COLDEF(WS_CTVAR)=WS_COLUNA THEN
	        WS_TEXTO              := WS_COLDEF(WS_CTVAR-1);
	        WS_COLDEF(WS_CTVAR-1) := WS_COLDEF(WS_CTVAR);
	        WS_COLDEF(WS_CTVAR)   := WS_TEXTO;
	        EXIT;
	    END IF;
	    IF  WS_COMANDO = 'COLRIGHT' AND WS_CTVAR < WS_COLDEF.COUNT AND WS_COLDEF.COUNT > 1 AND WS_COLDEF(WS_CTVAR)=WS_COLUNA THEN
	        WS_TEXTO                   := WS_COLDEF(WS_CTVAR+1);
	        WS_COLDEF(WS_CTVAR+1) := WS_COLDEF(WS_CTVAR);
	        WS_COLDEF(WS_CTVAR)   := WS_TEXTO;
	        EXIT;
	    END IF;
	END LOOP;
	WS_CTVAR	:= 0;
	WS_PIPE		:= '';
	LOOP
	    WS_CTVAR := WS_CTVAR + 1;
	    IF  WS_CTVAR > WS_COLDEF.COUNT THEN
	        EXIT;
	    END IF;
	    IF  WS_COMANDO IN ('DELETE','DELCUP') AND WS_COLDEF(WS_CTVAR) = WS_COLUNA THEN
	        WS_COLUNA := WS_COLUNA;
	    ELSE
		PRM_COLUNA := PRM_COLUNA||WS_PIPE||WS_COLDEF(WS_CTVAR);
		WS_PIPE := '|';
	    END IF;
	END LOOP;

    

	PRM_COLUP := '';
	WS_CTVAR  := 0;
    
	LOOP
	    WS_CTVAR := WS_CTVAR + 1;
	    IF  WS_CTVAR > WS_CUPDEF.COUNT THEN
	        EXIT;
	    END IF;

	    IF  WS_COMANDO = 'COLLEFT' AND WS_CTVAR > 1 AND WS_CUPDEF.COUNT > 1 AND WS_CUPDEF(WS_CTVAR)=WS_COLUNA THEN
	        WS_TEXTO              := WS_CUPDEF(WS_CTVAR-1);
	        WS_CUPDEF(WS_CTVAR-1) := WS_CUPDEF(WS_CTVAR);
	        WS_CUPDEF(WS_CTVAR)   := WS_TEXTO;
	        EXIT;
	    END IF;
	    IF  WS_COMANDO = 'COLRIGHT' AND WS_CTVAR < WS_CUPDEF.COUNT AND WS_CUPDEF.COUNT > 1 AND WS_CUPDEF(WS_CTVAR)=WS_COLUNA THEN
	        WS_TEXTO                   := WS_CUPDEF(WS_CTVAR+1);
	        WS_CUPDEF(WS_CTVAR+1) := WS_CUPDEF(WS_CTVAR);
	        WS_CUPDEF(WS_CTVAR)   := WS_TEXTO;
	        EXIT;
	    END IF;
	END LOOP;

	WS_CTVAR	:= 0;
	WS_PIPE		:= '';
	LOOP
	    WS_CTVAR := WS_CTVAR + 1;
	    IF  WS_CTVAR > WS_CUPDEF.COUNT THEN
	        EXIT;
	    END IF;
	    IF  WS_COMANDO IN ('DELETE','DELCOL') AND WS_CUPDEF(WS_CTVAR) = WS_COLUNA THEN
	        WS_COLUNA := WS_COLUNA;
	    ELSE
		PRM_COLUP := PRM_COLUP||WS_PIPE||WS_CUPDEF(WS_CTVAR);
		WS_PIPE := '|';
	    END IF;
	END LOOP;

	IF  WS_COMANDO = 'DIRECT' THEN
	    PRM_COLUNA := WS_COLUNA;
	END IF;

    

	WS_URL := 'dwu.upquery.main'	||'?prm_parametros='||PRM_PARAMETROS
					||'&prm_micro_visao='||PRM_MICRO_VISAO;

	PRM_COLUNA	:= TRIM(PRM_COLUNA);
	PRM_COLUP	:= TRIM(PRM_COLUP);
	PRM_AGRUPADORES := TRIM(PRM_AGRUPADORES);

	IF  PRM_COMANDO = 'ROLLOFF' THEN
	    WS_URL := WS_URL||'&prm_rp=CUBE';
	    PRM_RP := 'CUBE';
	END IF;

	IF  PRM_COMANDO IN ('ROLLON','INSPAV') THEN
	    WS_URL := WS_URL||'&prm_rp=ROLL';
	    PRM_RP := 'ROLL';
	END IF;

	IF  PRM_COMANDO NOT IN('ROLLON','ROLLOFF') THEN
	    WS_URL := WS_URL||'&prm_rp='||PRM_RP;
	END IF;

	IF  PRM_COMANDO = 'EDMODEON' THEN
	    WS_URL := WS_URL||'&prm_mode=ED';
	    PRM_MODE := 'ED';
	END IF;

	IF  PRM_COMANDO = 'EDMODEOFF' THEN
	    WS_URL := WS_URL||'&prm_mode=NO';
	    PRM_MODE := 'NO';
	END IF;

	IF  PRM_COMANDO NOT IN('EDMODEON','EDMODEOFF','INSPAV') THEN
	    WS_URL := WS_URL||'&prm_mode='||PRM_MODE;
	END IF;

	IF  PRM_COLUNA <> ' ' THEN
	    WS_URL := WS_URL||'&prm_coluna='||PRM_COLUNA;
	END IF;

	IF  PRM_AGRUPADORES <> ' ' THEN
	    WS_URL := WS_URL||'&prm_agrupador='||PRM_AGRUPADORES;
	END IF;

	IF  PRM_COLUP <> ' ' THEN
	    WS_URL := WS_URL||'&prm_colup='||PRM_COLUP;
	END IF;

	RETURN(WS_URL);
EXCEPTION WHEN OTHERS THEN
    HTP.P(WS_NULO);
END URL_DEFAULT;


FUNCTION VALOR_PONTO (  PRM_PARAMETROS   VARCHAR2 DEFAULT NULL,
						PRM_MICRO_VISAO	 VARCHAR2 DEFAULT NULL,
						PRM_OBJETO		 VARCHAR2 DEFAULT NULL, 
						PRM_SCREEN       VARCHAR2 DEFAULT NULL ) RETURN CHAR AS

	RET_COLUNA			LONG;

	WS_QUERY_PIVOT		LONG;
 	WS_AGRUPADOR		LONG;
	WS_SQL				LONG;
	WS_PARAMETROS		LONG;
 
	WS_LQUERY			NUMBER;
	WS_CURSOR			INTEGER;
	WS_LINHAS			INTEGER;
	WS_COUNTER			INTEGER;

	WS_QUERY_MONTADA	DBMS_SQL.VARCHAR2A;
	WS_NCOLUMNS			DBMS_SQL.VARCHAR2_TABLE;
	WS_PVCOLUMNS		DBMS_SQL.VARCHAR2_TABLE;
	WS_MFILTRO			DBMS_SQL.VARCHAR2_TABLE;
	WS_CAB_CROSS        VARCHAR2(4000);
    WS_QUERYOC clob;

BEGIN
	WS_PARAMETROS := PRM_PARAMETROS;

	IF  SUBSTR(WS_PARAMETROS,LENGTH(WS_PARAMETROS),1)='|' THEN
	    WS_PARAMETROS := WS_PARAMETROS||'1|1';
	END IF;

	WS_SQL := CORE.MONTA_QUERY_DIRECT(PRM_MICRO_VISAO, '', WS_PARAMETROS, 'SUMARY', '', WS_QUERY_PIVOT, WS_QUERY_MONTADA, WS_LQUERY, WS_NCOLUMNS, WS_PVCOLUMNS, WS_AGRUPADOR, WS_MFILTRO, PRM_OBJETO, PRM_SCREEN => PRM_SCREEN, PRM_CROSS => 'N', PRM_CAB_CROSS => WS_CAB_CROSS);
    
    WS_CURSOR := DBMS_SQL.OPEN_CURSOR;

	DBMS_SQL.PARSE( C => WS_CURSOR, STATEMENT => WS_QUERY_MONTADA, LB => 1, UB => WS_LQUERY, LFFLG => TRUE, LANGUAGE_FLAG => DBMS_SQL.NATIVE );

	WS_SQL := CORE.BIND_DIRECT(WS_PARAMETROS, WS_CURSOR, 'SUMARY', PRM_OBJETO, PRM_MICRO_VISAO, PRM_SCREEN);

	DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, 1, RET_COLUNA, 40);
	WS_LINHAS := DBMS_SQL.EXECUTE(WS_CURSOR);
	WS_LINHAS := DBMS_SQL.FETCH_ROWS(WS_CURSOR);
	DBMS_SQL.COLUMN_VALUE(WS_CURSOR, 1, RET_COLUNA);
	DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);

	RETURN(RET_COLUNA);

EXCEPTION
	WHEN OTHERS	 THEN
	   RETURN('0');
END VALOR_PONTO;

FUNCTION CDESC ( PRM_CODIGO  CHAR  DEFAULT NULL,
                 PRM_TABELA  CHAR DEFAULT NULL,
                 PRM_REVERSE BOOLEAN DEFAULT FALSE ) RETURN VARCHAR2 AS

    WS_DESCRICAO VARCHAR2(800);

    WS_SQL  VARCHAR2(2000);

    CURSOR CRS_CDESC IS
    SELECT NDS_TFISICA, NDS_CD_CODIGO, NDS_CD_EMPRESA, NDS_CD_DESCRICAO
    FROM CODIGO_DESCRICAO
    WHERE NDS_TABELA = UPPER(PRM_TABELA);

    WS_CDESC CRS_CDESC%ROWTYPE;
    WS_CURSOR INTEGER;
    --WS_PAR_EMP
    WS_LINHAS NUMBER;
    
BEGIN
    -- RETIRADO O EXECUTE IMMEDIATE POR QUESTÃO DE AUMENTO DE USO DE PROCESSAMENTO 04/04/2022
    
    OPEN  CRS_CDESC;
    FETCH CRS_CDESC INTO WS_CDESC;
    CLOSE CRS_CDESC;
    
    /*IF PRM_REVERSE = FALSE THEN
        WS_SQL := 'SELECT '||RTRIM(WS_CDESC.NDS_CD_DESCRICAO)||' FROM '||WS_CDESC.NDS_TFISICA||' WHERE '||WS_CDESC.NDS_CD_CODIGO||' = :COL';
    ELSE
        WS_SQL := 'SELECT '||RTRIM(WS_CDESC.NDS_CD_CODIGO)||' FROM '||WS_CDESC.NDS_TFISICA||' WHERE '||WS_CDESC.NDS_CD_DESCRICAO||' = :COL';
    END IF;

    EXECUTE IMMEDIATE WS_SQL INTO WS_DESCRICAO USING PRM_CODIGO;*/

    if prm_reverse = false then
        ws_sql := 'select '||rtrim(ws_cdesc.nds_cd_descricao)||' from '||ws_cdesc.nds_tfisica||' where '||ws_cdesc.nds_cd_codigo||' = :coluna';
    else
        ws_sql := 'select '||rtrim(ws_cdesc.nds_cd_codigo)||' from '||ws_cdesc.nds_tfisica||' where '||ws_cdesc.nds_cd_descricao||' = :coluna';
    end if;
    
    ws_cursor := dbms_sql.open_cursor;

    BEGIN
    dbms_sql.parse(ws_cursor, ws_sql, dbms_sql.native);
    dbms_sql.define_column(ws_cursor, 1, ws_descricao, 400);
    dbms_sql.bind_variable(ws_cursor, ':coluna',prm_codigo);

    ws_linhas := dbms_sql.execute(ws_cursor);

    ws_linhas := dbms_sql.fetch_rows(ws_cursor);

    dbms_sql.column_value(ws_cursor, 1, ws_descricao);

    dbms_sql.close_cursor(ws_cursor);
    EXCEPTION
        WHEN OTHERS THEN
            dbms_sql.close_cursor(ws_cursor);
    END;

    RETURN(NVL(TRIM(WS_DESCRICAO), PRM_CODIGO));

EXCEPTION WHEN OTHERS THEN
       RETURN(PRM_CODIGO);
END CDESC;

FUNCTION GETPROP (	PRM_OBJETO  VARCHAR2,
					PRM_PROP    VARCHAR2,
					PRM_SCREEN  VARCHAR2 DEFAULT 'DEFAULT',
                    PRM_USUARIO VARCHAR2 DEFAULT 'DWU',
                    PRM_TIPO    VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 RESULT_CACHE RELIES_ON (OBJECT_ATTRIB, OBJECT_PADRAO, BI_OBJECT_PADRAO) AS

	WS_PROP		VARCHAR2(400);
    WS_VALOR    VARCHAR2(4000);
    WS_TIPO     VARCHAR2(200);

BEGIN

    IF NVL(PRM_TIPO, 'N/A') = 'N/A' THEN
        IF PRM_OBJETO = 'DEFAULT' THEN
            WS_TIPO := 'DEFAULT';
        ELSE
            SELECT DECODE(TP_OBJETO, 'OBJETO', 'BARRAS', TP_OBJETO) INTO WS_TIPO FROM OBJETOS WHERE CD_OBJETO = TRIM(PRM_OBJETO);
        END IF;
    ELSE
        WS_TIPO := PRM_TIPO;
    END IF;

    WS_PROP := TRIM(PRM_PROP);

    
    
















    SELECT VALOR INTO WS_VALOR FROM (
        
        SELECT PROPRIEDADE AS VALOR
            FROM OBJECT_ATTRIB
            WHERE OWNER = PRM_USUARIO AND
                NAVEGADOR = 'DEFAULT' AND
                CD_OBJECT = TRIM(PRM_OBJETO) AND
                CD_PROP   = WS_PROP
        
        UNION ALL
        
        SELECT VL_DEFAULT AS VALOR
			FROM OBJECT_PADRAO
			WHERE CD_PROP   = WS_PROP AND (
                (    TP_OBJETO = WS_TIPO)
				OR 
                (    WS_TIPO IN (SELECT COLUMN_VALUE FROM TABLE(FUN.VPIPE(TP_OBJETO)))    )
			) AND ROWNUM = 1
        
        UNION ALL

        SELECT VL_DEFAULT AS VALOR
			FROM BI_OBJECT_PADRAO
			WHERE CD_PROP   = WS_PROP AND (
                ( TP_OBJETO = WS_TIPO )
				OR 
                ( WS_TIPO IN (SELECT COLUMN_VALUE FROM TABLE(FUN.VPIPE(TP_OBJETO))))

			) AND ROWNUM = 1
    ) WHERE ROWNUM = 1;

	RETURN(TRIM(WS_VALOR));

	EXCEPTION
		WHEN OTHERS THEN
			RETURN(WS_VALOR);
END GETPROP;


FUNCTION GETPROPS (  PRM_OBJETO  VARCHAR2,
                     PRM_TIPO    VARCHAR2,
					 PRM_PROP    VARCHAR2,
                     PRM_USUARIO VARCHAR2 DEFAULT 'DWU' ) RETURN ARR RESULT_CACHE RELIES_ON (BI_OBJECT_PADRAO) AS

    WS_ARR ARR;
    WS_COUNT NUMBER := 1;

    CURSOR CRS_VALORES IS
        SELECT COALESCE(PROPRIEDADE, T2.VL_DEFAULT, T1.VL_DEFAULT) AS VALOR
        FROM BI_OBJECT_PADRAO T1
        LEFT JOIN 
        OBJECT_PADRAO T2 ON T2.CD_PROP = T1.CD_PROP AND T2.TP_OBJETO =  PRM_TIPO AND T2.CD_PROP = T1.CD_PROP
        LEFT JOIN 
        OBJECT_ATTRIB T3 ON T3.CD_PROP = T1.CD_PROP AND T3.CD_OBJECT = PRM_OBJETO AND OWNER = PRM_USUARIO AND T3.CD_PROP = T1.CD_PROP
        WHERE  T1.TP_OBJETO = PRM_TIPO AND T1.CD_PROP IN (
            SELECT COLUMN_VALUE FROM TABLE((FUN.VPIPE(PRM_PROP)))
            )
        AND NVL(T1.SUFIXO, 'N/A') <> 'N/A'
        ORDER BY T1.CD_PROP;
    WS_VALOR CRS_VALORES%ROWTYPE;

    WS_ATTRIBS VARCHAR2(4000);

BEGIN

    

    













    WS_ARR    := ARR();

    OPEN CRS_VALORES;
        LOOP
            FETCH CRS_VALORES INTO WS_VALOR;
            EXIT WHEN CRS_VALORES%NOTFOUND;
            WS_ARR.EXTEND;
            WS_ARR(WS_COUNT) := WS_VALOR.VALOR;
            WS_COUNT := WS_COUNT+1;
    END LOOP;
    CLOSE CRS_VALORES;

    RETURN WS_ARR;

    

END GETPROPS;


FUNCTION PUT_STYLE (  PRM_OBJETO    VARCHAR2,
					  PRM_PROP      VARCHAR2,
					  PRM_TP_OBJETO VARCHAR2,
					  PRM_VALUE     VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 RESULT_CACHE RELIES_ON (BI_OBJECT_PADRAO) AS

	WS_PROP		   VARCHAR2(70);
	WS_SCRIPT	   VARCHAR2(70);
	WS_PROPRIEDADE VARCHAR2(4000);
    WS_NULO        VARCHAR2(1) := NULL;

BEGIN

	SELECT BI_OBJECT_PADRAO.SCRIPT, NVL(OBJECT_ATTRIB.PROPRIEDADE, BI_OBJECT_PADRAO.VL_DEFAULT) INTO WS_SCRIPT, WS_PROPRIEDADE
	FROM   OBJECT_ATTRIB, BI_OBJECT_PADRAO
	WHERE OWNER = 'DWU' AND
	    OBJECT_ATTRIB.NAVEGADOR = 'DEFAULT' AND
		OBJECT_ATTRIB.SCREEN    = 'DEFAULT' AND
	    OBJECT_ATTRIB.CD_OBJECT = TRIM(PRM_OBJETO) AND
	    OBJECT_ATTRIB.CD_PROP   = TRIM(PRM_PROP) AND
        OBJECT_ATTRIB.CD_PROP   = TRIM(BI_OBJECT_PADRAO.CD_PROP) AND
        DECODE(PRM_TP_OBJETO, 'GRAFICO', 'BARRAS', PRM_TP_OBJETO) = DECODE(TRIM(BI_OBJECT_PADRAO.TP_OBJETO), 'GRAFICO', 'BARRAS', TRIM(BI_OBJECT_PADRAO.TP_OBJETO)) AND ROWNUM = 1;

	BEGIN
		SELECT HTML INTO WS_SCRIPT
		FROM SCRIPT_TO_HTML WHERE SCRIPT=TRIM(WS_SCRIPT);
	EXCEPTION
		WHEN OTHERS THEN
		    WS_SCRIPT := WS_SCRIPT;
	END;

	IF  NVL(TRIM(WS_SCRIPT),'%*%') <> '%*%' AND NVL(TRIM(WS_PROPRIEDADE),'%*%') <> '%*%' THEN
        IF(PRM_VALUE = 'value') THEN
		    RETURN(RTRIM(WS_PROPRIEDADE));
		ELSE
		    RETURN(TRIM(WS_SCRIPT)||':'||RTRIM(WS_PROPRIEDADE)||'; ');
		END IF;
	ELSE
	    RETURN(WS_NULO);
	END IF;

	EXCEPTION
		WHEN OTHERS THEN
		    RETURN(WS_NULO);
END PUT_STYLE;


FUNCTION RET_SINAL (  PRM_OBJETO    VARCHAR2,
					  PRM_COLUNA    VARCHAR2,
					  PRM_CONTEUDO  VARCHAR2 ) RETURN VARCHAR2 AS

	WS_PROP		VARCHAR2(70);
	WS_SINAL	VARCHAR2(70);
	WS_PROPRIEDADE  VARCHAR2(70);
	WS_TIPO		VARCHAR2(1);
	WS_FX01		VARCHAR2(30);
	WS_FX02		VARCHAR2(30);
	WS_FX03		VARCHAR2(30);
	WS_FX04		VARCHAR2(30);
	WS_FX05		VARCHAR2(30);
    WS_USUARIO  VARCHAR2(80);

BEGIN

    WS_USUARIO := GBL.GETUSUARIO;
   
    BEGIN
	SELECT NVL(CD_SINAL,'%$%') INTO WS_SINAL
	FROM   SINAL_COLUNA
	WHERE  (CD_USUARIO = WS_USUARIO OR CD_USUARIO IN (SELECT CD_GROUP FROM GUSERS_ITENS WHERE CD_USUARIO = WS_USUARIO) OR CD_USUARIO = 'DWU') AND
		CD_OBJETO = PRM_OBJETO AND
		CD_COLUNA = PRM_COLUNA;
    EXCEPTION
	WHEN OTHERS THEN
	     RETURN('');
    END;

	IF  WS_SINAL='%$%' THEN
	    RETURN('');
	END IF;

    BEGIN
	SELECT NVL(FX_01,'%$%'), FX_02, FX_03, FX_04, FX_05, TP_SINAL INTO WS_FX01, WS_FX02, WS_FX03, WS_FX04, WS_FX05, WS_TIPO
	FROM   SINAIS
	WHERE   CD_SINAL=WS_SINAL;
    EXCEPTION
	WHEN OTHERS THEN
	     RETURN(' ');
    END;

	IF  WS_FX01 = '%$%' THEN
	    RETURN('');
	END IF;

	IF  TO_NUMBER(PRM_CONTEUDO) <= TO_NUMBER(WS_FX01) THEN
	    RETURN(HTF.IMG(FUN.R_GIF('ind'||WS_TIPO||'_1','PNG')));
	END IF;

	IF  TO_NUMBER(PRM_CONTEUDO) <= TO_NUMBER(WS_FX02) THEN
	    RETURN(HTF.IMG(FUN.R_GIF('ind'||WS_TIPO||'_2','PNG')));
	END IF;

	IF  TO_NUMBER(PRM_CONTEUDO) <= TO_NUMBER(WS_FX03) THEN
	    RETURN(HTF.IMG(FUN.R_GIF('ind'||WS_TIPO||'_3','PNG')));
	END IF;

	IF  TO_NUMBER(PRM_CONTEUDO) <= TO_NUMBER(WS_FX04) THEN
	    RETURN(HTF.IMG(FUN.R_GIF('ind'||WS_TIPO||'_4','PNG')));
	END IF;

	RETURN(HTF.IMG(FUN.R_GIF('ind'||WS_TIPO||'_5','PNG')));

	EXCEPTION
		WHEN OTHERS THEN
		    RETURN('');

END RET_SINAL;


FUNCTION PUT_PAR ( PRM_OBJETO     VARCHAR2,
                   PRM_PROP       VARCHAR2,
                   PRM_TP_OBJETO  VARCHAR2,
                   PRM_OWNER      VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

 WS_PROP         VARCHAR2(70);
 WS_SCRIPT       VARCHAR2(70);
 WS_PROPRIEDADE  VARCHAR2(4000);
 WS_COUNT        NUMBER;
 WS_USUARIO      VARCHAR2(70);
 WS_COUNT_DWU    NUMBER;
 WS_NULO         VARCHAR2(1) := NULL;

BEGIN

    IF PRM_OWNER IS NULL THEN
        WS_USUARIO := GBL.GETUSUARIO;
    ELSE
		WS_USUARIO := PRM_OWNER;
	END IF;
	
	SELECT COUNT(*) INTO WS_COUNT_DWU
	FROM OBJECT_ATTRIB
	WHERE OWNER = 'DWU' AND
	OBJECT_ATTRIB.NAVEGADOR = 'DEFAULT' AND
	OBJECT_ATTRIB.CD_OBJECT = TRIM(PRM_OBJETO) AND
	OBJECT_ATTRIB.CD_PROP   = TRIM(PRM_PROP);
		

	IF WS_COUNT_DWU > 0 THEN
		
		SELECT COUNT(*) INTO WS_COUNT_DWU
		FROM OBJECT_ATTRIB , OBJECT_PADRAO
		WHERE OWNER = 'DWU' AND
			OBJECT_ATTRIB.NAVEGADOR = 'DEFAULT' AND
			OBJECT_ATTRIB.CD_OBJECT = TRIM(PRM_OBJETO) AND
			OBJECT_ATTRIB.CD_PROP   = TRIM(PRM_PROP) AND
			OBJECT_ATTRIB.CD_PROP   = TRIM(OBJECT_PADRAO.CD_PROP) AND
			PRM_TP_OBJETO           = TRIM(OBJECT_PADRAO.TP_OBJETO);
			
		IF WS_COUNT_DWU > 0 THEN
		
			SELECT OBJECT_PADRAO.SCRIPT, PROPRIEDADE INTO WS_SCRIPT, WS_PROPRIEDADE
			FROM OBJECT_ATTRIB , OBJECT_PADRAO
			WHERE OWNER = 'DWU' AND
				OBJECT_ATTRIB.NAVEGADOR = 'DEFAULT' AND
				OBJECT_ATTRIB.CD_OBJECT = TRIM(PRM_OBJETO) AND
				OBJECT_ATTRIB.CD_PROP   = TRIM(PRM_PROP) AND
				OBJECT_ATTRIB.CD_PROP   = TRIM(OBJECT_PADRAO.CD_PROP) AND
				PRM_TP_OBJETO           = TRIM(OBJECT_PADRAO.TP_OBJETO);
		ELSE
		
		    SELECT BI_OBJECT_PADRAO.SCRIPT, PROPRIEDADE INTO WS_SCRIPT, WS_PROPRIEDADE
			FROM OBJECT_ATTRIB , BI_OBJECT_PADRAO
			WHERE OWNER = 'DWU' AND
				OBJECT_ATTRIB.NAVEGADOR = 'DEFAULT' AND
				OBJECT_ATTRIB.CD_OBJECT = TRIM(PRM_OBJETO) AND
				OBJECT_ATTRIB.CD_PROP   = TRIM(PRM_PROP) AND
				OBJECT_ATTRIB.CD_PROP   = TRIM(BI_OBJECT_PADRAO.CD_PROP) AND
				TRIM(BI_OBJECT_PADRAO.TP_OBJETO) LIKE '%'||PRM_TP_OBJETO||'%';
		
		END IF;
	ELSE
	    SELECT COUNT(*) INTO WS_COUNT
		FROM OBJECT_ATTRIB
		WHERE OWNER = WS_USUARIO AND
			OBJECT_ATTRIB.NAVEGADOR = 'DEFAULT' AND
			OBJECT_ATTRIB.CD_OBJECT = TRIM(PRM_OBJETO) AND
			OBJECT_ATTRIB.CD_PROP   = TRIM(PRM_PROP);
	
		IF  WS_COUNT > 0 THEN
			SELECT OBJECT_PADRAO.SCRIPT, PROPRIEDADE INTO WS_SCRIPT, WS_PROPRIEDADE
			FROM OBJECT_ATTRIB , OBJECT_PADRAO
			WHERE OWNER = WS_USUARIO AND
				OBJECT_ATTRIB.NAVEGADOR = 'DEFAULT' AND
				OBJECT_ATTRIB.CD_OBJECT = TRIM(PRM_OBJETO) AND
				OBJECT_ATTRIB.CD_PROP   = TRIM(PRM_PROP) AND
				OBJECT_ATTRIB.CD_PROP   = TRIM(OBJECT_PADRAO.CD_PROP) AND
				TRIM(OBJECT_PADRAO.TP_OBJETO) LIKE '%'||PRM_TP_OBJETO||'%';
		ELSE
			SELECT SCRIPT, VL_DEFAULT INTO WS_SCRIPT, WS_PROPRIEDADE
			FROM OBJECT_PADRAO WHERE
			CD_PROP = PRM_PROP AND
			TP_OBJETO = PRM_TP_OBJETO;
		END IF;
	END IF;

 IF  NVL(TRIM(WS_SCRIPT),'%*%') <> '%*%' AND NVL(TRIM(WS_PROPRIEDADE),'%*%') <> '%*%' THEN
     RETURN(RTRIM(WS_PROPRIEDADE));
 ELSE
     RETURN(WS_NULO);
 END IF;

 EXCEPTION
  WHEN OTHERS THEN
       RETURN(WS_NULO);

END PUT_PAR;


FUNCTION COL_NAME (	PRM_CD_COLUNA   VARCHAR2 DEFAULT NULL,
					PRM_MICRO_VISAO VARCHAR2,
					PRM_CONDICAO	VARCHAR2 DEFAULT '',
					PRM_CONTEUDO	VARCHAR2,
					PRM_COLOR       VARCHAR2 DEFAULT '#000000',
					PRM_TITLE       VARCHAR2 DEFAULT 'Filtro do drill',
					PRM_REPEAT      BOOLEAN  DEFAULT FALSE,
					PRM_AGRUPADO    VARCHAR2 DEFAULT NULL ) RETURN VARCHAR AS

	WS_COUNT	NUMBER;
	WS_LIGACAO	VARCHAR2(100);
	WS_RETORNO	VARCHAR2(3000) := '';
	WS_COLUNA   VARCHAR2(3000);
    WS_USUARIO  VARCHAR2(80);
	WS_FUNDO    VARCHAR2(40);
	WS_FONTE    VARCHAR2(40);
	WS_TIPO     VARCHAR2(40);
    WS_PADRAO   VARCHAR2(200);

BEGIN

    WS_PADRAO := GBL.GETLANG;
    
	BEGIN
		SELECT NVL((FUN.UTRANSLATE('NM_ROTULO', PRM_MICRO_VISAO, NM_ROTULO, WS_PADRAO)), INITCAP(PRM_CD_COLUNA)), CD_LIGACAO INTO WS_COLUNA, WS_LIGACAO
		FROM MICRO_COLUNA
		WHERE TRIM(CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO) AND TRIM(CD_COLUNA)=TRIM(PRM_CD_COLUNA);
	EXCEPTION
		WHEN OTHERS THEN
			WS_COLUNA := '';
			WS_LIGACAO := '';
	END;
    
	IF LENGTH(TRIM(PRM_CONTEUDO)) > 0 THEN
		
        IF PRM_REPEAT = FALSE THEN
			IF PRM_COLOR <> 'destaque' THEN
				WS_RETORNO := '<li class="desc" title="'||PRM_TITLE||'">'||WS_COLUNA||' '||PRM_CONDICAO||'</li>';
			ELSE
				WS_RETORNO := '<li class="desc" title="'||FUN.LANG(PRM_COLOR)||'">'||WS_COLUNA||' '||PRM_CONDICAO||' '||PRM_CONTEUDO||'</li>';
			END IF;
		END IF;

		IF PRM_COLOR <> 'destaque' THEN
			IF  WS_LIGACAO <> 'SEM' THEN
				WS_RETORNO := WS_RETORNO||' <li class="'||PRM_COLOR||' valor" title="'||TRIM(PRM_CD_COLUNA)||': '||PRM_CONTEUDO||'">'||FUN.CDESC(PRM_CONTEUDO,WS_LIGACAO)||' '||PRM_AGRUPADO||'</li>';
			ELSE
				WS_RETORNO := WS_RETORNO||' <li class="'||PRM_COLOR||' valor" title="'||TRIM(PRM_CD_COLUNA)||'">'||PRM_CONTEUDO||' '||PRM_AGRUPADO||'</li>';
			END IF;
		ELSE
            WS_USUARIO := GBL.GETUSUARIO;
			SELECT COR_FUNDO, COR_FONTE, TIPO_DESTAQUE INTO WS_FUNDO, WS_FONTE, WS_TIPO FROM DESTAQUE T1 WHERE CD_DESTAQUE = PRM_TITLE AND (T1.CD_USUARIO = WS_USUARIO OR T1.CD_USUARIO = 'DWU' OR T1.CD_USUARIO IN (SELECT CD_GROUP FROM GUSERS_ITENS T2 WHERE T2.CD_USUARIO = WS_USUARIO)) AND CD_COLUNA = PRM_CD_COLUNA AND ROWNUM = 1;
			
			WS_RETORNO := WS_RETORNO||' <li class="valor" title="'||FUN.LANG('Destaque')||'">';
			WS_RETORNO := WS_RETORNO||' <span style="background-color: '||WS_FONTE||';">FONTE</span><span style="background-color: '||WS_FUNDO||';">FUNDO</li>';
		END IF;

	END IF;

	RETURN(WS_RETORNO);

END COL_NAME;

FUNCTION CHECK_USER ( PRM_USUARIO VARCHAR2 DEFAULT USER ) RETURN BOOLEAN AS

	WS_COUNT	NUMBER := 0;

BEGIN

	SELECT COUNT(*) INTO WS_COUNT
	FROM USUARIOS
	WHERE USU_NOME = PRM_USUARIO AND STATUS='A';

	IF  WS_COUNT > 0 THEN
	    RETURN(TRUE);
	ELSE
	    RETURN(FALSE);
	END IF;

END CHECK_USER;

FUNCTION VCALC (  PRM_CD_COLUNA   VARCHAR2,
				  PRM_MICRO_VISAO VARCHAR2 ) RETURN BOOLEAN AS

	WS_TIPO		CHAR(1);

BEGIN

	BEGIN
		SELECT NVL(TIPO,'A') INTO WS_TIPO
		FROM MICRO_COLUNA
		WHERE TRIM(CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO) AND TRIM(CD_COLUNA)=TRIM(PRM_CD_COLUNA);
	EXCEPTION
	     WHEN OTHERS THEN
	        RETURN(FALSE);
	END;

	IF  WS_TIPO='C' THEN
	    RETURN(TRUE);
	ELSE
	    RETURN(FALSE);
	END IF;

END VCALC;


FUNCTION XCALC (  PRM_CD_COLUNA    VARCHAR2, 
                  PRM_MICRO_VISAO  VARCHAR2, 
                  PRM_SCREEN       VARCHAR2 ) RETURN VARCHAR2 AS

 WS_FORMULA    VARCHAR2(8000);
 WS_AGRUPADOR  VARCHAR2(10);
 WS_FLEX       VARCHAR2(80);
BEGIN

    BEGIN
    
		SELECT NVL(FORMULA,' '), ST_AGRUPADOR, FLEXCOL INTO WS_FORMULA, WS_AGRUPADOR, WS_FLEX
		FROM MICRO_COLUNA
		WHERE TRIM(CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO) AND TRIM(CD_COLUNA)=TRIM(PRM_CD_COLUNA);
    EXCEPTION
        WHEN OTHERS THEN
            WS_FORMULA := ' ';
    END;

    IF WS_AGRUPADOR = 'SEM' AND NVL(WS_FLEX, 'N/A') = 'N/A' THEN
        WS_FORMULA := FUN.SUBPAR(WS_FORMULA, PRM_SCREEN);
    ELSE
        WS_FORMULA := FUN.GFORMULA2(PRM_MICRO_VISAO, PRM_CD_COLUNA, PRM_SCREEN);
    END IF;

 RETURN(WS_FORMULA);

END XCALC;

FUNCTION XEXEC ( WS_CONTENT  VARCHAR2 DEFAULT NULL, 
	             PRM_SCREEN  VARCHAR2 DEFAULT NULL, 
	             PRM_ATUAL   VARCHAR2 DEFAULT NULL, 
	             PRM_ANT     VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

 WS_TCONT  VARCHAR2(3000);
 WS_CALCULADO  VARCHAR2(2000);

 WS_CURSOR INTEGER;
 WS_LINHAS INTEGER;
 WS_SQL  VARCHAR2(2000);
 WS_NULO VARCHAR2(1) := NULL;

BEGIN

 WS_TCONT := WS_CONTENT;

 IF  UPPER(SUBSTR(WS_TCONT,1,5)) = 'EXEC=' THEN
     WS_TCONT := REPLACE(UPPER(WS_TCONT), 'EXEC=','');
     WS_TCONT := REPLACE(WS_TCONT, '$[SCREEN]', FUN.NOMEOBJETO(PRM_SCREEN));
     WS_TCONT := REPLACE(WS_TCONT, '$[BEFORE]', NVL(PRM_ANT, 0));
     WS_TCONT := REPLACE(WS_TCONT, '$[SELF]', NVL(PRM_ATUAL, 0));
     WS_TCONT := REPLACE(WS_TCONT, '$[CONCAT]','||');
	 WS_TCONT := REPLACE(WS_TCONT, '$[NOW]', TRIM(TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI')));
	 WS_TCONT := REPLACE(WS_TCONT, '$[DOWNLOAD]', 'dwu.fcl.download?arquivo=');
     WS_TCONT := FUN.XFORMULA(WS_TCONT, PRM_SCREEN,'S');
     WS_SQL := 'select '||TRIM(WS_TCONT)||' from dual';
     WS_CURSOR := DBMS_SQL.OPEN_CURSOR;
     DBMS_SQL.PARSE(WS_CURSOR, WS_SQL, DBMS_SQL.NATIVE);
     DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, 1, WS_CALCULADO, 600);

     WS_LINHAS := DBMS_SQL.EXECUTE(WS_CURSOR);
     WS_LINHAS := DBMS_SQL.FETCH_ROWS(WS_CURSOR);

     DBMS_SQL.COLUMN_VALUE(WS_CURSOR, 1, WS_CALCULADO);
     DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
     WS_TCONT := WS_CALCULADO;
 END IF;

 RETURN(WS_TCONT);
 
 EXCEPTION WHEN OTHERS THEN
    RETURN(WS_TCONT);
END XEXEC;


FUNCTION SETEM (  PRM_STR1 VARCHAR2,
				  PRM_STR2 VARCHAR2 ) RETURN BOOLEAN AS
						
	WS_COUNT NUMBER;
BEGIN

   SELECT COUNT(*) INTO WS_COUNT FROM TABLE((FUN.VPIPE(PRM_STR1))) WHERE PRM_STR2 = COLUMN_VALUE;

	IF  WS_COUNT > 0 THEN
	    RETURN (TRUE);
	ELSE
	    RETURN (FALSE);
	END IF;

END SETEM;


FUNCTION ISNUMBER ( PRM_VALOR VARCHAR2 DEFAULT NULL ) RETURN BOOLEAN IS
    WS_VALOR NUMBER;
BEGIN
    WS_VALOR := TO_NUMBER(PRM_VALOR);
    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;

FUNCTION IFMASCARA ( STR1 IN VARCHAR2,
                     CMASCARA VARCHAR2,
                     PRM_CD_MICRO_VISAO VARCHAR2 DEFAULT '$[no_mv]',
                     PRM_CD_COLUNA VARCHAR2 DEFAULT '$[no_co]',
                     PRM_OBJETO VARCHAR2 DEFAULT '$[no_ob]',
                     PRM_TIPO VARCHAR2 DEFAULT 'micro_coluna',
                     PRM_FORMULA VARCHAR2 DEFAULT NULL,
                     PRM_SCREEN  VARCHAR2 DEFAULT NULL,
                     PRM_USUARIO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

    WS_CALCULADO     VARCHAR2(2600);

    WS_CURSOR          INTEGER;
    WS_LINHAS          INTEGER;
    WS_SQL             VARCHAR2(2600);

    WS_SAIDA           VARCHAR2(800);
    WS_OBJETO          VARCHAR2(300);
    WS_COLUNA          VARCHAR2(300);
    WS_CMASCARA        VARCHAR2(300);
    WS_CD_COLUNA       VARCHAR2(300);
    WS_TEXTO           VARCHAR2(4000);
    WS_NM_VAR          VARCHAR2(300);
    WS_FLEXCOL         VARCHAR2(300);
    WS_MASCARA_DEFAULT VARCHAR2(300);
    WS_COUNT           NUMBER;
    WS_USUARIO         VARCHAR2(80);

BEGIN

    IF NVL(PRM_USUARIO, 'N/A') = 'N/A' THEN
        WS_USUARIO := GBL.GETUSUARIO;
    ELSE
        WS_USUARIO := PRM_USUARIO;
    END IF;
	 
	WS_CD_COLUNA := PRM_CD_COLUNA;
    WS_CMASCARA  := CMASCARA;
    WS_TEXTO     := PRM_FORMULA;
    WS_MASCARA_DEFAULT := '';
     
    BEGIN
        SELECT FLEXCOL INTO WS_FLEXCOL
        FROM MICRO_COLUNA WHERE 
        CD_MICRO_VISAO = TRIM(PRM_CD_MICRO_VISAO) AND
        CD_COLUNA      = TRIM(WS_CD_COLUNA);
    EXCEPTION WHEN OTHERS THEN
        WS_FLEXCOL := '';
    END;
    
    IF NVL(TRIM(WS_FLEXCOL), 'N/A') <> 'N/A' THEN

        SELECT COUNT(*) INTO WS_COUNT FROM PARAMETRO_USUARIO WHERE CD_PADRAO = WS_FLEXCOL AND CD_USUARIO = WS_USUARIO;

        IF WS_COUNT <> 0 THEN
	        SELECT  NM_MASCARA INTO WS_CMASCARA
	        FROM MICRO_COLUNA
	        WHERE   CD_MICRO_VISAO = PRM_CD_MICRO_VISAO AND
	        UPPER(TRIM(CD_COLUNA)) = (SELECT UPPER(TRIM(CONTEUDO)) FROM PARAMETRO_USUARIO WHERE CD_PADRAO = WS_FLEXCOL AND CD_USUARIO = WS_USUARIO);
	    ELSE
            SELECT  NM_MASCARA INTO WS_CMASCARA
	        FROM MICRO_COLUNA
	        WHERE   CD_MICRO_VISAO = PRM_CD_MICRO_VISAO AND
	        UPPER(TRIM(CD_COLUNA)) = (SELECT UPPER(TRIM(CONTEUDO)) FROM PARAMETRO_USUARIO WHERE CD_PADRAO = WS_FLEXCOL AND CD_USUARIO = 'DWU');
        END IF;

    





    END IF;

      IF  WS_CD_COLUNA <> '$[no_co]' AND PRM_CD_MICRO_VISAO <> '$[no_mv]' THEN
          BEGIN
         IF PRM_TIPO = 'micro_coluna' THEN
       SELECT NVL(ST_RESTRICAO,'NO') INTO WS_COLUNA
       FROM   COLUMN_RESTRICTION
       WHERE  USUARIO        = WS_USUARIO AND
        CD_MICRO_VISAO = PRM_CD_MICRO_VISAO AND
        CD_COLUNA      = WS_CD_COLUNA;
    ELSE
       SELECT NVL(ST_RESTRICAO,'NO') INTO WS_COLUNA
       FROM   COLUMN_RESTRICTION
       WHERE  USUARIO        = WS_USUARIO AND
        CD_MICRO_VISAO = PRM_CD_MICRO_VISAO AND
        CD_COLUNA      = WS_CD_COLUNA;
    END IF;
          EXCEPTION
              WHEN OTHERS THEN WS_COLUNA := 'NO';
          END;
      ELSE
          WS_COLUNA := 'NO';
      END IF;

      IF  PRM_OBJETO <> '$[no_ob]' THEN
          BEGIN
              SELECT NVL(ST_RESTRICAO,'NO') INTO WS_OBJETO
              FROM   OBJECT_RESTRICTION
              WHERE  USUARIO        = WS_USUARIO AND
                     CD_OBJETO      = PRM_OBJETO;
          EXCEPTION
              WHEN OTHERS THEN WS_OBJETO := 'NO';
          END;
      ELSE
          WS_OBJETO := 'NO';
      END IF;

      IF  WS_OBJETO = 'NO' AND WS_COLUNA = 'NO' THEN
          IF  WS_CMASCARA = 'SEM' THEN
              RETURN (STR1);
          ELSE
              IF  SUBSTR(FUN.CDESC(WS_CMASCARA,'MASCARAS'),1,4)='DRE=' THEN
                  BEGIN
                       WS_SAIDA := TO_NUMBER(STR1);
                       WS_SAIDA := FUN.APPLY_DRE_MASC(SUBSTR(FUN.CDESC(WS_CMASCARA,'MASCARAS'),5,LENGTH(WS_CMASCARA)), STR1);
                  EXCEPTION
                       WHEN OTHERS THEN
                            WS_SAIDA := STR1;
                  END;
                  RETURN(WS_SAIDA);
              ELSE
                  IF  SUBSTR(FUN.CDESC(WS_CMASCARA,'MASCARAS'),1,5)='EXEC=' THEN
                      BEGIN
                         WS_SAIDA := REPLACE(FUN.CDESC(WS_CMASCARA,'MASCARAS'),'EXEC=','');
                         WS_SAIDA := REPLACE(WS_SAIDA,'$[SELF]',CHR(39)||STR1||CHR(39));

                        WS_SQL := 'select '||RTRIM(WS_SAIDA)||' from dual';
                        WS_CURSOR := DBMS_SQL.OPEN_CURSOR;
                        DBMS_SQL.PARSE(WS_CURSOR, WS_SQL, DBMS_SQL.NATIVE);
                        DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, 1, WS_CALCULADO, 400);

                        WS_LINHAS := DBMS_SQL.EXECUTE(WS_CURSOR);
                        WS_LINHAS := DBMS_SQL.FETCH_ROWS(WS_CURSOR);

                        DBMS_SQL.COLUMN_VALUE(WS_CURSOR, 1, WS_CALCULADO);
                        DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
                        WS_SAIDA := WS_CALCULADO;

                      EXCEPTION
                         WHEN OTHERS THEN
                              WS_SAIDA := '?MASC?';
                      END;
                      RETURN (NVL(WS_SAIDA, '&nbsp;'));
                  ELSE

                     IF FUN.CDESC(WS_CMASCARA,'MASCARAS') = '-' THEN
                        RETURN('');
                      END IF;

                        BEGIN
                            WS_SAIDA := TO_DATE(TRIM(STR1));
                        IF INSTR(FUN.CDESC(WS_CMASCARA,'MASCARAS'), 'HH24:MI') > 0 THEN
						    WS_SAIDA := STR1; 
                        ELSE
					        WS_SAIDA := TO_CHAR(TO_DATE(TRIM(STR1)),FUN.CDESC(WS_CMASCARA,'MASCARAS'),'NLS_DATE_LANGUAGE='||FUN.RET_VAR('LANG_DATE'));
					    END IF;
					    EXCEPTION WHEN OTHERS THEN
                            IF UPPER(SUBSTR(CMASCARA,1,5))='(ABS)' THEN
                                WS_SAIDA := TO_CHAR(ABS(TO_NUMBER(TRIM(STR1))),FUN.CDESC(WS_CMASCARA,'MASCARAS'),'NLS_NUMERIC_CHARACTERS = '||CHR(39)||FUN.RET_VAR('POINT')||CHR(39));
                            ELSE
                                WS_SAIDA := TO_CHAR(TO_NUMBER(TRIM(STR1)),FUN.CDESC(WS_CMASCARA,'MASCARAS'),'NLS_NUMERIC_CHARACTERS = '||CHR(39)||FUN.RET_VAR('POINT')||CHR(39));
                            END IF;
                      END;
                      RETURN (WS_SAIDA);
                  END IF;
              END IF;
          END IF;
      ELSE
          RETURN('...');
      END IF;

EXCEPTION
    WHEN OTHERS THEN
	RETURN(STR1);
END IFMASCARA;

FUNCTION MASCARAJS ( PRM_MASCARA VARCHAR2, PRM_TIPO VARCHAR2 DEFAULT 'texto' ) RETURN VARCHAR2 AS 

    WS_MASCARA VARCHAR2(80);

BEGIN

    CASE PRM_TIPO
        WHEN 'texto' THEN
            WS_MASCARA := PRM_MASCARA;
        WHEN 'number' THEN
            WS_MASCARA := REPLACE(PRM_MASCARA, '0', '9');
            WS_MASCARA := REPLACE(WS_MASCARA, 'G', '.');
            WS_MASCARA := REPLACE(WS_MASCARA, 'D', ',');
        ELSE
            WS_MASCARA := PRM_MASCARA;
    END CASE;

    RETURN WS_MASCARA;

END MASCARAJS;

FUNCTION UM ( PRM_COLUNA  VARCHAR2 DEFAULT '$[no_co]',
              PRM_VISAO   VARCHAR2 DEFAULT '$[no_ob]',
              PRM_CONTENT VARCHAR2 DEFAULT NULL,
              PRM_UM      VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS
	  
	WS_UNIDADE VARCHAR2(20);
    WS_NULO    VARCHAR2(1) := NULL; 

BEGIN
    
	IF LENGTH(TRIM(PRM_CONTENT)) > 0 THEN
		
		IF NVL(PRM_UM, 'N/A') = 'N/A' THEN
            SELECT NM_UNIDADE 
            INTO WS_UNIDADE 
            FROM MICRO_COLUNA
            WHERE CD_MICRO_VISAO = PRM_VISAO AND 
            CD_COLUNA = PRM_COLUNA;
        ELSE
            WS_UNIDADE := PRM_UM;
        END IF;
		
		IF INSTR(WS_UNIDADE, '>') = 1 THEN
			RETURN PRM_CONTENT||' '||TRIM(REPLACE(WS_UNIDADE, '>', ''));
		ELSIF INSTR(WS_UNIDADE, '<') = 1 THEN
			RETURN TRIM(REPLACE(WS_UNIDADE, '<', ''))||' '||PRM_CONTENT;
		ELSE
			RETURN PRM_CONTENT;
		END IF;
		
	ELSE
	
	    RETURN WS_NULO;
		
	END IF;
     
EXCEPTION
    WHEN OTHERS THEN
        RETURN WS_NULO;
END UM;


FUNCTION IFNOTNULL ( STR1 IN VARCHAR2, STR2 IN VARCHAR2 ) RETURN VARCHAR2 IS

BEGIN
   IF (STR1 IS NULL)
     THEN RETURN (NULL);
     ELSE RETURN (STR2);
   END IF;
END IFNOTNULL;


FUNCTION VERIFICA_DATA ( CHK_DATA VARCHAR DEFAULT NULL ) RETURN VARCHAR2 AS

	WS_DATA DATE;
	WS_ERRO EXCEPTION;

BEGIN
	IF  CHK_DATA = ' ' OR NVL(CHK_DATA,' ') = ' ' THEN
	    RAISE WS_ERRO;
	END IF;

	WS_DATA := TO_DATE(CHK_DATA,'dd/mm/yyyy');
	RETURN (TO_CHAR(WS_DATA,'dd/mm/yyyy'));
EXCEPTION
	WHEN WS_ERRO THEN
		RETURN ('Invalida');
	WHEN OTHERS THEN
		RETURN ('Invalida');

END VERIFICA_DATA;


FUNCTION R_GIF ( PRM_GIF_NOME  VARCHAR2 DEFAULT NULL,
                 PRM_TYPE      VARCHAR2 DEFAULT 'GIF',
                 PRM_LOCATION  VARCHAR2 DEFAULT 'LOCAL' ) RETURN VARCHAR2 AS

        WS_URL      VARCHAR2(2000);

BEGIN
        IF  PRM_LOCATION = 'LOCAL' THEN
            WS_URL := 'dwu.fcl.download?arquivo='||PRM_GIF_NOME||FCL.FPDATA(PRM_TYPE,'GOO','','.'||LOWER(PRM_TYPE));
        ELSE
            IF  UPPER(PRM_GIF_NOME) = 'PATH' THEN
                WS_URL := FUN.RET_VAR('URL_GIFS');
            ELSE
                WS_URL := FUN.RET_VAR('URL_GIFS')||RTRIM(PRM_GIF_NOME)||FCL.FPDATA(PRM_TYPE,'GOO','','.'||LOWER(PRM_TYPE));
            END IF;
        END IF;
 
 RETURN WS_URL;
 
 HTP.P('');

END R_GIF;

FUNCTION SUBPAR ( PRM_TEXTO  VARCHAR2 DEFAULT NULL, 
                  PRM_SCREEN VARCHAR2 DEFAULT NULL, 
                  PRM_DESC   VARCHAR2 DEFAULT 'Y' ) RETURN VARCHAR2 AS

    WS_TEXTO       VARCHAR2(3000);
    WS_FUNCAO      VARCHAR2(3000);
    WS_VAR         VARCHAR2(1000);
    WS_AGRUPADOR   VARCHAR2(20);
    WS_TIPO        VARCHAR2(1);
    WS_USUARIO     VARCHAR2(80);

    WS_COUNT NUMBER;

BEGIN

    WS_COUNT := 0;
    WS_TEXTO := PRM_TEXTO||'#FIM';
    WS_FUNCAO := '';

LOOP
    WS_COUNT := WS_COUNT + 1;
    IF  SUBSTR(WS_TEXTO,WS_COUNT,4)='#FIM' THEN
        EXIT;
    END IF;

    IF  SUBSTR(WS_TEXTO,WS_COUNT,1) IN ('$', '@', '#') AND INSTR(PRM_TEXTO, '$') <> LENGTH(TRIM(PRM_TEXTO)) THEN
        WS_TIPO := SUBSTR(WS_TEXTO,WS_COUNT,1);
        WS_VAR  := '';
        WS_COUNT := WS_COUNT + 1;
        IF  SUBSTR(WS_TEXTO,WS_COUNT,1)<>'[' THEN
            WS_FUNCAO := WS_FUNCAO||SUBSTR(WS_TEXTO,(WS_COUNT-1),1);
            WS_FUNCAO := WS_FUNCAO||SUBSTR(WS_TEXTO, WS_COUNT,   1);
        ELSE
            LOOP
               WS_COUNT  := WS_COUNT + 1;
               IF  SUBSTR(WS_TEXTO,WS_COUNT,1)=']' THEN
                   
                   IF  WS_TIPO = '$' THEN
                        WS_FUNCAO := WS_FUNCAO||FUN.GPARAMETRO(UPPER(WS_VAR), PRM_DESC, PRM_SCREEN);
                        EXIT;
                   END IF;

				   IF  WS_TIPO = '@' THEN
					   WS_FUNCAO := WS_FUNCAO||FUN.GVALOR(UPPER(WS_VAR), PRM_SCREEN);
                       EXIT;
                   END IF;

                   IF  WS_TIPO = '#' THEN
					   WS_FUNCAO := WS_FUNCAO||FUN.RET_VAR(UPPER(WS_VAR), USER);
                       EXIT;
                   END IF;

               END IF;
               WS_VAR := WS_VAR||SUBSTR(WS_TEXTO,WS_COUNT,1);
            END LOOP;
        END IF;
    ELSE
        WS_FUNCAO := WS_FUNCAO||SUBSTR(WS_TEXTO,WS_COUNT,1);
    END IF;

END LOOP;

    IF UPPER(SUBSTR(WS_FUNCAO,1,5)) = 'EXEC=' THEN
        WS_FUNCAO := FUN.XEXEC(WS_FUNCAO, PRM_SCREEN); 
    END IF;
    
RETURN(WS_FUNCAO);
EXCEPTION WHEN OTHERS THEN
    INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SUBPAR', USER, 'ERRO');
    COMMIT;
END SUBPAR;





























FUNCTION CALL_DRILL ( PRM_DRILL VARCHAR DEFAULT 'N', 
					  PRM_PARAMETROS LONG,
					  PRM_SCREEN LONG,
					  PRM_OBJID CHAR DEFAULT NULL,
					  PRM_MICRO_VISAO CHAR DEFAULT NULL,
					  PRM_COLUNA CHAR DEFAULT NULL,
					  PRM_SELECTED NUMBER DEFAULT 1,
					  PRM_TRACK VARCHAR2 DEFAULT NULL, 
					  PRM_OBJETON VARCHAR2 DEFAULT NULL ) RETURN CLOB AS
					   
	CURSOR CRS_XGOTO(PRM_USUARIO VARCHAR2) IS
		SELECT CD_OBJETO_GO, (SELECT TP_OBJETO FROM OBJETOS WHERE CD_OBJETO = CD_OBJETO_GO) AS TIPO, (SELECT NM_OBJETO FROM OBJETOS WHERE CD_OBJETO = CD_OBJETO_GO) AS NOME
		FROM GOTO_OBJETO WHERE CD_OBJETO = PRM_OBJID AND
		    FUN.CHECK_PERMISSAO(CD_OBJETO_GO) = 'S' AND CD_OBJETO_GO NOT IN (SELECT COLUMN_VALUE FROM TABLE(FUN.VPIPE(PRM_TRACK)) WHERE COLUMN_VALUE IS NOT NULL) 
			AND CD_OBJETO_GO NOT IN ( SELECT CD_OBJETO FROM OBJECT_RESTRICTION WHERE USUARIO = PRM_USUARIO )
		ORDER BY TIPO, NOME;

	WS_XGOTO CRS_XGOTO%ROWTYPE;
	
    CURSOR CRS_FILTROS_OBJETO IS
        SELECT TRIM(CD_COLUNA)||'|'||DECODE(RTRIM(CONDICAO),'IGUAL','$[IGUAL]','DIFERENTE','$[DIFERENTE]','MAIOR','$[MAIOR]','MENOR','$[MENOR]','MAIOROUIGUAL','$[MAIOROUIGUAL]','MENOROUIGUAL','$[MENOROUIGUAL]','LIKE','$[LIKE]','NOTLIKE','$[NOTLIKE]','$[IGUAL]')||RTRIM(CONTEUDO) AS COLUNA
        FROM FILTROS
        WHERE TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND
            TRIM(CD_OBJETO) IN (TRIM(PRM_OBJID), TRIM(PRM_SCREEN)) AND
            TRIM(CD_USUARIO)  = 'DWU' AND 
            TP_FILTRO = 'objeto' AND
            LIGACAO <> 'or' AND
			ST_AGRUPADO = 'N' AND CONDICAO <> 'NOFLOAT' AND CONDICAO <> 'NOFILTER';

    WS_FILTROS_OBJETO CRS_FILTROS_OBJETO%ROWTYPE;
					  
	WS_CLEARDRILL VARCHAR2(40);
	WS_COUNTER NUMBER := 1;
	WS_GODRILL			LONG;
	WS_GODRILL2			LONG;
	WS_SEARCHDRILL		LONG;
	WS_CCOLUNA			NUMBER := 1;
	WS_COLUNA           LONG;
	WS_OBJID			VARCHAR2(40);
	WS_PARAMETROS		CLOB;
	WS_FILTRO           NUMBER;
	WS_COUNT            NUMBER;
	WS_GRUPO VARCHAR2(40);
	WS_COLUP VARCHAR2(2000);
	WS_REOPEN VARCHAR2(8000);
	WS_OBJETON   VARCHAR2(2000); 
    WS_SUBQUERY	VARCHAR2(900);
	WS_ROTULO   VARCHAR2(900);
	WS_PARAMETROS_UNICOS LONG;
	WS_TITLE            VARCHAR2(800);
	
	TYPE WS_TMCOLUNAS IS TABLE OF MICRO_COLUNA%ROWTYPE
	INDEX BY PLS_INTEGER;
	RET_MCOL			WS_TMCOLUNAS;
	WS_TIPO             VARCHAR2(40) := 'N/A';
    WS_USUARIO          VARCHAR2(80);
	WS_ADMIN            VARCHAR2(20);
BEGIN

    WS_USUARIO := GBL.GETUSUARIO;
    WS_ADMIN   := GBL.GETNIVEL;

    WS_OBJETON := PRM_OBJETON;
	WS_SUBQUERY := FUN.PUT_PAR(PRM_OBJID,'SUBQUERY', 'CONSULTA');
	WS_SUBQUERY := SUBSTR(WS_SUBQUERY, 1, LENGTH(WS_SUBQUERY)-1);
    SELECT COUNT(*) INTO WS_FILTRO FROM OBJECT_ATTRIB WHERE CD_PROP = 'FILTRO' AND PROPRIEDADE = 'ISOLADO' AND CD_OBJECT = PRM_OBJID;
	
	IF WS_FILTRO = 0 THEN
		OPEN CRS_FILTROS_OBJETO;
			LOOP
				FETCH CRS_FILTROS_OBJETO INTO WS_FILTROS_OBJETO;
				EXIT WHEN CRS_FILTROS_OBJETO%NOTFOUND;
				WS_PARAMETROS := WS_PARAMETROS||WS_FILTROS_OBJETO.COLUNA||'|';
				WS_PARAMETROS_UNICOS := WS_PARAMETROS||WS_FILTROS_OBJETO.COLUNA||'|';
			END LOOP;
		CLOSE CRS_FILTROS_OBJETO;
	END IF;
	
	WS_PARAMETROS := WS_PARAMETROS||PRM_PARAMETROS;

    IF  PRM_DRILL = 'Y' THEN
	    WS_CLEARDRILL := '';
	ELSE
	    WS_CLEARDRILL := 'cleardrill();';
	END IF;

	WS_COUNTER := 0;
	
	WS_OBJID := PRM_OBJID;
	
	WS_PARAMETROS := REPLACE(REPLACE(WS_PARAMETROS, CHR(39), '\&apos;'), '||', '$[CONCAT]');
	
	OPEN CRS_XGOTO(WS_USUARIO);
		LOOP
			FETCH CRS_XGOTO INTO WS_XGOTO;
			EXIT WHEN CRS_XGOTO%NOTFOUND;
			
			IF WS_XGOTO.TIPO <> WS_TIPO THEN
			    WS_SEARCHDRILL := WS_SEARCHDRILL||'<optgroup label="'||WS_XGOTO.TIPO||'">'||WS_XGOTO.TIPO||'</optgroup>';
				WS_TIPO := WS_XGOTO.TIPO;
			END IF;
			
			IF FUN.GETPROP(TRIM(WS_XGOTO.CD_OBJETO_GO),'FILTRO') = 'INTERROMPIDO' THEN
			    WS_SEARCHDRILL := WS_SEARCHDRILL||'<option data-param="'||WS_PARAMETROS_UNICOS||'" data-tipo="'||WS_XGOTO.TIPO||'" value="'||WS_XGOTO.CD_OBJETO_GO||'">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', WS_XGOTO.CD_OBJETO_GO, WS_XGOTO.NOME))||'</option>';			
			ELSIF FUN.GETPROP(TRIM(WS_XGOTO.CD_OBJETO_GO),'FILTRO') = 'PASSIVO' THEN
			    WS_SEARCHDRILL := WS_SEARCHDRILL||'<option data-param="'||WS_PARAMETROS||'" data-tipo="'||WS_XGOTO.TIPO||'" value="'||WS_XGOTO.CD_OBJETO_GO||'">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', WS_XGOTO.CD_OBJETO_GO, WS_XGOTO.NOME))||'</option>';
			ELSIF FUN.GETPROP(TRIM(WS_XGOTO.CD_OBJETO_GO),'FILTRO') = 'COM CORTE' THEN
			    WS_SEARCHDRILL := WS_SEARCHDRILL||'<option data-param="" data-tipo="'||WS_XGOTO.TIPO||'" value="'||WS_XGOTO.CD_OBJETO_GO||'">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', WS_XGOTO.CD_OBJETO_GO, WS_XGOTO.NOME))||'</option>';
			ELSIF FUN.GETPROP(TRIM(WS_XGOTO.CD_OBJETO_GO),'FILTRO') = 'ISOLADO' THEN
			    WS_SEARCHDRILL := WS_SEARCHDRILL||'<option data-param="" data-isolado="S" data-tipo="'||WS_XGOTO.TIPO||'" value="'||WS_XGOTO.CD_OBJETO_GO||'">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', WS_XGOTO.CD_OBJETO_GO, WS_XGOTO.NOME))||'</option>';
			ELSE
			    WS_SEARCHDRILL := WS_SEARCHDRILL||'<option data-param="'||WS_PARAMETROS||'" data-tipo="'||WS_XGOTO.TIPO||'" value="'||WS_XGOTO.CD_OBJETO_GO||'">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', WS_XGOTO.CD_OBJETO_GO, WS_XGOTO.NOME))||'</option>';
			END IF;

			WS_COUNTER := WS_COUNTER + 1;
		END LOOP;
	CLOSE CRS_XGOTO;

	WS_COUNT := 0;
	SELECT COUNT(*) INTO WS_COUNT FROM OBJECT_ATTRIB WHERE OWNER = WS_USUARIO AND CD_PROP = 'DRILL' AND PROPRIEDADE = 'CENTER';
	
	WS_OBJETON := REPLACE(WS_OBJETON, '>    >', '>');
	

	IF INSTR(WS_OBJETON, 'REABRIR') <> 0 THEN
	    WS_REOPEN := '';
		WS_OBJETON := REPLACE(WS_OBJETON, 'REABRIR', '');
	ELSE
	    WS_REOPEN := '<option style="color: #CC3333;" value="'||WS_OBJID||'" data-param="'||WS_PARAMETROS||'">'||FUN.LANG('REABRIR')||'</option>';
	END IF;
	
	IF LENGTH(WS_OBJETON) = 3 THEN
	    WS_TITLE := '';
	ELSE
	    WS_TITLE := WS_OBJETON;
	END IF;
	
	WS_GODRILL := '<li><select style="float: left;" title="'||WS_TITLE||'" onchange="drillChange(this, encodeURIComponent(this.options[this.selectedIndex].getAttribute(&#039;data-param&#039;)), &#039;'||PRM_TRACK||'&#039;, &#039;'||WS_OBJETON||'&#039;, &#039;'||WS_COUNT||'&#039;, &#039;'||PRM_OBJID||'&#039;);"><option value="" selected hidden>'||FUN.LANG('ABRIR')||':</option>'||WS_SEARCHDRILL||WS_REOPEN||'</select></li><li>';
	
	SELECT NVL(CS_COLUP, 'n/a') INTO WS_COLUP FROM PONTO_AVALIACAO WHERE CD_PONTO = PRM_OBJID;
	IF(WS_COLUP = 'n/a') THEN
	    WS_GODRILL := WS_GODRILL||'<span class="reorder" title="'||FUN.LANG('clique para alterar a ordem')||'"></span>';
	END IF;
		
	SELECT CD_GRUPO INTO WS_GRUPO FROM OBJETOS WHERE CD_OBJETO = PRM_OBJID;
	
	WS_COUNTER := 0;
	FOR A IN(SELECT NM_ROTULO FROM MICRO_COLUNA WHERE CD_COLUNA IN (SELECT * FROM TABLE(FUN.VPIPE(PRM_COLUNA))) AND CD_MICRO_VISAO = PRM_MICRO_VISAO) LOOP
		IF WS_COUNTER > 0 THEN
			WS_ROTULO := WS_ROTULO||'|'||REPLACE(REPLACE(A.NM_ROTULO, CHR(10), ''), CHR(13), '');
		ELSE
			WS_ROTULO := REPLACE(REPLACE(A.NM_ROTULO, CHR(10), ''), CHR(13), '');
		END IF;
		WS_COUNTER := WS_COUNTER+1;
	END LOOP;
	
	IF PRM_SELECTED = 1 THEN
		IF WS_ADMIN = 'A' THEN
			WS_GODRILL := WS_GODRILL||'<span class="bolt" title="'||FUN.LANG('ponto de avalia&ccedil;&atilde;o')||'" onclick="quickPa(&#039;'||PRM_MICRO_VISAO||'&#039;, &#039;'||WS_GRUPO||'&#039;, &#039;VALOR&#039;, &#039;&#039;, &#039;&#039;, this);"></span></td>';
			WS_GODRILL := WS_GODRILL||'<span class="pizza" title="'||FUN.LANG('gr&aacute;fico de pizza')||'" onclick="quickPa(&#039;'||PRM_MICRO_VISAO||'&#039;, &#039;'||WS_GRUPO||'&#039;, &#039;PIZZA&#039;, &#039;'||PRM_COLUNA||'&#039;, &#039;'||WS_ROTULO||'&#039;, this);"></span>';
			WS_GODRILL := WS_GODRILL||'<span class="grafico" title="'||FUN.LANG('gr&aacute;fico de linha')||'" onclick="quickPa(&#039;'||PRM_MICRO_VISAO||'&#039;, &#039;'||WS_GRUPO||'&#039;, &#039;LINHAS&#039;, &#039;'||PRM_COLUNA||'&#039;, &#039;'||WS_ROTULO||'&#039;, this);"></span>';
			WS_GODRILL := WS_GODRILL||'<span class="bar" title="'||FUN.LANG('gr&aacute;fico de barra')||'" onclick="quickPa(&#039;'||PRM_MICRO_VISAO||'&#039;, &#039;'||WS_GRUPO||'&#039;, &#039;BARRAS&#039;, &#039;'||PRM_COLUNA||'&#039;, &#039;'||WS_ROTULO||'&#039;, this);"></span>';
			WS_GODRILL := WS_GODRILL||'<span class="map" title="'||FUN.LANG('gr&aacute;fico de mapa')||'" onclick="quickPa(&#039;'||PRM_MICRO_VISAO||'&#039;, &#039;'||WS_GRUPO||'&#039;, &#039;MAPA&#039;, &#039;'||PRM_COLUNA||'&#039;, &#039;'||WS_ROTULO||'&#039;, this);"></span>';
		    WS_GODRILL := WS_GODRILL||'<span class="gauge" title="'||FUN.LANG('ponteiro')||'" onclick="quickPa(&#039;'||PRM_MICRO_VISAO||'&#039;, &#039;'||WS_GRUPO||'&#039;, &#039;PONTEIRO&#039;, &#039;'||PRM_COLUNA||'&#039;, &#039;'||WS_ROTULO||'&#039;, this);"></span>';
		ELSE
			WS_GODRILL := WS_GODRILL||'<span class="pizza" title="'||FUN.LANG('gr&aacute;fico de pizza')||'" onclick="quickPa(&#039;'||PRM_MICRO_VISAO||'&#039;, &#039;'||WS_GRUPO||'&#039;, &#039;PIZZA&#039;, &#039;'||PRM_COLUNA||'&#039;, &#039;'||WS_ROTULO||'&#039;, this);"></span>';
			WS_GODRILL := WS_GODRILL||'<span class="grafico" title="'||FUN.LANG('gr&aacute;fico de linha')||'" onclick="quickPa(&#039;'||PRM_MICRO_VISAO||'&#039;, &#039;'||WS_GRUPO||'&#039;, &#039;LINHAS&#039;, &#039;'||PRM_COLUNA||'&#039;, &#039;'||WS_ROTULO||'&#039;, this);"></span>';
			WS_GODRILL := WS_GODRILL||'<span class="bar" title="'||FUN.LANG('gr&aacute;fico de barra')||'" onclick="quickPa(&#039;'||PRM_MICRO_VISAO||'&#039;, &#039;'||WS_GRUPO||'&#039;, &#039;BARRAS&#039;, &#039;'||PRM_COLUNA||'&#039;, &#039;'||WS_ROTULO||'&#039;, this);"></span>';
		END IF;
    END IF;
	
	WS_GODRILL := WS_GODRILL||'';
	RETURN(WS_GODRILL);
	
END CALL_DRILL;

FUNCTION NOME_COL ( PRM_CD_COLUNA VARCHAR2,
                    PRM_MICRO_VISAO VARCHAR2, 
                    PRM_SCREEN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS
					
    WS_NOME_COL VARCHAR2(200);

BEGIN

    SELECT NM_ROTULO INTO WS_NOME_COL
    FROM MICRO_COLUNA
    WHERE TRIM(CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO) AND TRIM(CD_COLUNA)=TRIM(REPLACE(PRM_CD_COLUNA, '|', ''));

    RETURN(WS_NOME_COL);

EXCEPTION
    WHEN OTHERS THEN
        RETURN(PRM_CD_COLUNA);
END NOME_COL;

FUNCTION MAPOUT ( PRM_PARAMETROS   VARCHAR2 DEFAULT NULL,
				  PRM_MICRO_VISAO  CHAR DEFAULT NULL,
				  PRM_COLUNA       CHAR DEFAULT NULL,
				  PRM_AGRUPADOR    CHAR DEFAULT NULL,
				  PRM_MODE         CHAR DEFAULT 'NO',
				  PRM_OBJETO       VARCHAR2 DEFAULT NULL,
				  PRM_SCREEN       VARCHAR2 DEFAULT NULL,
				  PRM_COLUP        VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

        CURSOR CRS_COLSB IS
                         SELECT COLUMN_VALUE AS CD_COLUNA
                         FROM TABLE(FUN.VPIPE(PRM_AGRUPADOR))
                         WHERE TRIM(COLUMN_VALUE) IS NOT NULL;

        WS_COLSB        CRS_COLSB%ROWTYPE;

    CURSOR CRS_MICRO_VISAO IS
    SELECT RTRIM(CD_GRUPO_FUNCAO) AS CD_GRUPO_FUNCAO
    FROM  MICRO_VISAO WHERE NM_MICRO_VISAO = PRM_MICRO_VISAO;

    WS_MICRO_VISAO   CRS_MICRO_VISAO%ROWTYPE;

    TYPE WS_TMCOLUNAS  IS TABLE OF MICRO_COLUNA%ROWTYPE
            INDEX BY PLS_INTEGER;

    TYPE GENERIC_CURSOR IS   REF CURSOR;

    CRS_SAIDA   GENERIC_CURSOR;

    CURSOR NC_COLUNAS IS  SELECT * FROM MICRO_COLUNA WHERE CD_MICRO_VISAO = PRM_MICRO_VISAO;


    RET_COLUNA   VARCHAR2(100);
    RET_MCOL   WS_TMCOLUNAS;

    WS_NCOLUMNS   DBMS_SQL.VARCHAR2_TABLE;
    WS_COLUNA_ANT  DBMS_SQL.VARCHAR2_TABLE;
    WS_PVCOLUMNS  DBMS_SQL.VARCHAR2_TABLE;
    WS_MFILTRO   DBMS_SQL.VARCHAR2_TABLE;
    WS_VCOL    DBMS_SQL.VARCHAR2_TABLE;
    WS_VCON    DBMS_SQL.VARCHAR2_TABLE;


    WS_GRFT    VARCHAR2(40);
    WS_ZEBRADO   VARCHAR2(20);
    WS_PIPE    CHAR(1);
    WS_VIRG    CHAR(1);
    WS_ADD    VARCHAR(10);
    WS_GOOBJETO                     VARCHAR2(100);
    WS_GOCOUNT                      NUMBER;

    WS_POSX    VARCHAR(5);
    WS_POSY    VARCHAR(5);

    RET_COLUP   LONG;
    WS_LQUERY   NUMBER;
    WS_VALOR   VARCHAR2(40);
    WS_COUNTER   NUMBER := 1;
    WS_COUNTER_PV   NUMBER := 0;
    WS_CCOLUNA   NUMBER := 1;
    WS_XCOLUNA   NUMBER := 0;
    WS_CTX    NUMBER := 0;
    WS_CHCOR   NUMBER := 0;
    WS_BINDN   NUMBER := 0;
    WS_SCOL    NUMBER := 0;
    WS_CSPAN   NUMBER := 0;
    WS_XCOUNT   NUMBER := 0;
    WS_MULTI                        NUMBER := 0;
    WS_CT_AGRUPADOR                 NUMBER := 0;

    WS_FONTE   LONG;
    WS_TEXTO   LONG;
    WS_TEXTOT   LONG;
    WS_NM_VAR   LONG;
    WS_CT_VAR   LONG;
    WS_NULO    LONG;
    WS_CONTENT_ANT   LONG;
    WS_URL_DEFAULT   LONG;
    WS_COLUP   LONG;
    WS_COLUNA   LONG;
    WS_AGRUPADOR   LONG;
    WS_RP    LONG;
    WS_XATALHO   LONG;
    WS_ATALHO   LONG;
    WS_RETORNO   LONG;
    WS_PARAMETROS   LONG;
    WS_PERC_COL   LONG;
    WS_FIND_COL   LONG;
    WS_PARENTY    LONG;

    WS_ACESSO   EXCEPTION;
    WS_SEMQUERY   EXCEPTION;
    WS_SEMPERMISSAO   EXCEPTION;
    WS_VCOLUNA   INTEGER;
    WS_PCURSOR   INTEGER;
    WS_CURSOR   INTEGER;
    WS_CSPANX   INTEGER;
    WS_SPAC    INTEGER;
    WS_LINHAS   INTEGER;
    WS_QUERY_MONTADA  DBMS_SQL.VARCHAR2A;
    WS_QUERY_PIVOT   LONG;
    WS_SQL    LONG;
    WS_SQL_PIVOT   LONG;
    WS_CHAMADA   LONG  := '$$';
    WS_SCRIPT   LONG;
    WS_LOCAIS   LONG;
    WS_MODE    VARCHAR2(30);

    WS_VAZIO   BOOLEAN := TRUE;
    WS_NODATA         EXCEPTION;
    WS_INVALIDO   EXCEPTION;
    WS_PONTO_AVALICAO  EXCEPTION;
    WS_CLOSE_HTML   EXCEPTION;
    WS_MOUNT   EXCEPTION;

    WS_COUNTL   NUMBER;

    WS_VPAR    DBMS_SQL.VARCHAR2_TABLE;
    WS_CATEGORIAS                   LONG;
    WS_DATASETS                     DBMS_SQL.VARCHAR2_TABLE;

    WS_II VARCHAR2(3);
    WS_COUNT NUMBER;
    WS_CAB_CROSS VARCHAR2(4000);
    WS_VALORSHOW     VARCHAR2(400);

BEGIN

    WS_COLUNA    := PRM_COLUNA;
    WS_AGRUPADOR := PRM_AGRUPADOR;
    WS_MODE      := PRM_MODE;
    WS_RP      := 'GRUPO';
    WS_GRFT      := WS_MODE;
    WS_COLUP     := '';
    WS_PARENTY   := PRM_COLUP;

    

    OPEN CRS_MICRO_VISAO;
    FETCH CRS_MICRO_VISAO INTO WS_MICRO_VISAO;
    CLOSE CRS_MICRO_VISAO;

    WS_TEXTO := PRM_PARAMETROS;
    WS_PARAMETROS := PRM_PARAMETROS;
    WS_PARAMETROS := FUN.CHECK_VALUE(WS_PARAMETROS);

    WS_URL_DEFAULT := FUN.URL_DEFAULT( WS_PARAMETROS, PRM_MICRO_VISAO, WS_AGRUPADOR, WS_COLUNA, WS_RP, WS_COLUP, '', WS_MODE );

    OPEN NC_COLUNAS;
    LOOP
        FETCH NC_COLUNAS BULK COLLECT INTO RET_MCOL LIMIT 200;
        EXIT WHEN NC_COLUNAS%NOTFOUND;
    END LOOP;
    CLOSE NC_COLUNAS;

            WS_CTX := 0;
    OPEN CRS_COLSB;
    LOOP
        FETCH CRS_COLSB INTO WS_COLSB;
        EXIT WHEN CRS_COLSB%NOTFOUND;

                WS_CTX := WS_CTX + 1;
                WS_DATASETS(WS_CTX) := '<dataSet seriesName="'||REPLACE(FUN.UTRANSLATE('NM_ROTULO', PRM_MICRO_VISAO, FUN.CHECK_ROTULOC(WS_COLSB.CD_COLUNA,PRM_MICRO_VISAO, PRM_SCREEN)), '<BR>', '')||'"';

                SELECT COUNT(*) INTO WS_GOCOUNT
                FROM   TABLE(FUN.VPIPE(WS_PARENTY))
                WHERE TRIM(COLUMN_VALUE) IS NOT NULL AND
                      COLUMN_VALUE=WS_COLSB.CD_COLUNA;

                IF  WS_GOCOUNT < 1 THEN
                    WS_DATASETS(WS_CTX) := WS_DATASETS(WS_CTX)||' renderAs="Line" ';
                END IF;


                WS_DATASETS(WS_CTX) := WS_DATASETS(WS_CTX)||'>';

    END LOOP;
    CLOSE CRS_COLSB;


    WS_COUNTER := 0;
    LOOP
        WS_COUNTER := WS_COUNTER + 1;
        IF  WS_COUNTER > RET_MCOL.COUNT THEN
        EXIT;
        END IF;

        IF  RTRIM(RET_MCOL(WS_COUNTER).ST_AGRUPADOR) <> 'SEM' AND FUN.SETEM(WS_AGRUPADOR,RTRIM(RET_MCOL(WS_COUNTER).CD_COLUNA)) THEN
    WS_SCOL := WS_SCOL + 1;
        END IF;

    END LOOP;

    WS_TEXTO := WS_PARAMETROS;

    WS_SQL := CORE.MONTA_QUERY_DIRECT(PRM_MICRO_VISAO, WS_COLUNA, WS_PARAMETROS, WS_RP, WS_COLUP, WS_QUERY_PIVOT, WS_QUERY_MONTADA, WS_LQUERY, WS_NCOLUMNS, WS_PVCOLUMNS, WS_AGRUPADOR, WS_MFILTRO, PRM_OBJETO, 'Y', PRM_SCREEN => PRM_SCREEN, PRM_CROSS => 'N', PRM_CAB_CROSS => WS_CAB_CROSS);


    WS_CURSOR := DBMS_SQL.OPEN_CURSOR;

    DBMS_SQL.PARSE( C => WS_CURSOR, STATEMENT => WS_QUERY_MONTADA, LB => 1, UB => WS_LQUERY, LFFLG => TRUE, LANGUAGE_FLAG => DBMS_SQL.NATIVE );

    WS_SQL := CORE.BIND_DIRECT(WS_PARAMETROS, WS_CURSOR, '', PRM_OBJETO, PRM_MICRO_VISAO, PRM_SCREEN );


    WS_COLUNA := FUN.CHECK_VALUE(WS_COLUNA);

    WS_COUNTER := 0;
    LOOP
        WS_COUNTER := WS_COUNTER + 1;
        IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
        EXIT;
        END IF;
        DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, WS_COUNTER, RET_COLUNA, 40);
    END LOOP;
    WS_LINHAS := DBMS_SQL.EXECUTE(WS_CURSOR);


    WS_COUNTER := 0;
    LOOP
        WS_COUNTER := WS_COUNTER + 1;
        IF  WS_COUNTER > RET_MCOL.COUNT OR WS_NCOLUMNS(1) = RET_MCOL(WS_COUNTER).CD_COLUNA THEN
        EXIT;
        END IF;
    END LOOP;

    WS_PIPE     := 'B';
    WS_PERC_COL := '';

    WS_COUNTL := 0;

    SELECT COUNT(*) INTO WS_MULTI
    FROM TABLE(FUN.VPIPE(PRM_AGRUPADOR))
    WHERE TRIM(COLUMN_VALUE) IS NOT NULL;

    IF  WS_MULTI > 1 THEN
        WS_RETORNO := WS_RETORNO||'<map decimalSeparator="," thousandSeparator="." fillColor="D7F4FF" includeValueInLabels="1" labelSepChar=": " baseFontSize="9"><data>'||CHR(13);
        LOOP
            WS_LINHAS := DBMS_SQL.FETCH_ROWS(WS_CURSOR);
            IF  WS_LINHAS = 1 THEN
                WS_VAZIO := FALSE;
            ELSE
                IF  WS_VAZIO = TRUE THEN
                    DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
                    RAISE WS_NODATA;
                END IF;
                EXIT;
            END IF;

            WS_XCOUNT  := 0;
            WS_CTX     := 0;

            WS_XCOUNT := WS_XCOUNT + 1;
            WS_CTX    := WS_CTX    + 1;
            DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_XCOUNT, RET_COLUNA);
            WS_PERC_COL := RET_COLUNA;
            WS_FIND_COL := WS_PERC_COL;

            IF RET_MCOL(WS_COUNTER).CD_LIGACAO <> 'SEM' THEN
                WS_XCOUNT := WS_XCOUNT + 1;
                WS_PERC_COL := RET_COLUNA;
                DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_XCOUNT, RET_COLUNA);
            END IF;

            IF  WS_PIPE = 'B' THEN
                WS_CATEGORIAS := '<categories font="Arial" fontSize="12" fontColor="000000">';
            END IF;
            
            WS_CATEGORIAS := WS_CATEGORIAS||CHR(13)||'<category label="'||WS_PERC_COL||'"/>';
            WS_CT_AGRUPADOR := 0;

            LOOP
                WS_CT_AGRUPADOR := WS_CT_AGRUPADOR + 1;
                IF  WS_CT_AGRUPADOR > WS_MULTI THEN
                    EXIT;
                END IF;

                WS_XCOUNT := WS_XCOUNT + 1;
                WS_CTX    := WS_CTX    + 1;
                DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_XCOUNT, RET_COLUNA);
                WS_PERC_COL := RET_COLUNA;

                WS_VALOR := TO_NUMBER(NVL(RET_COLUNA,0));

                WS_DATASETS(WS_CT_AGRUPADOR) := WS_DATASETS(WS_CT_AGRUPADOR)||CHR(13)||'<set value="'||WS_VALOR||'" />';

            END LOOP;

            WS_PIPE := '0';

        END LOOP;

        WS_RETORNO := WS_RETORNO||CHR(13)||WS_CATEGORIAS||CHR(13)||'</categories>';

        WS_CT_AGRUPADOR := 0;
        
        LOOP
            WS_CT_AGRUPADOR := WS_CT_AGRUPADOR + 1;
            IF  WS_CT_AGRUPADOR > WS_MULTI THEN
                EXIT;
            END IF;
            WS_RETORNO := WS_RETORNO||CHR(13)||WS_DATASETS(WS_CT_AGRUPADOR)||CHR(13)||'</dataSet>';
        END LOOP;
    ELSE
        WS_RETORNO := WS_RETORNO||'<map borderColor="005879" fillColor="FFFFFF" numberSuffix="" includeValueInLabels="1" labelSepChar=": " baseFontSize="9"><data>'||CHR(13);
 
	    LOOP
	        WS_COUNTL := WS_COUNTL+1;
            WS_LINHAS := DBMS_SQL.FETCH_ROWS(WS_CURSOR);
            IF  WS_LINHAS = 1 THEN
                WS_VAZIO := FALSE;
            ELSE
                IF  WS_VAZIO = TRUE THEN
                    DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
                    RAISE WS_NODATA;
                END IF;
                EXIT;
            END IF;

            WS_XCOUNT  := 0;

            WS_XCOUNT := WS_XCOUNT + 1;
            DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_XCOUNT, RET_COLUNA);
            WS_PERC_COL := RET_COLUNA;
            WS_FIND_COL := WS_PERC_COL;
            WS_XCOUNT := WS_XCOUNT + 1;
            DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_XCOUNT, RET_COLUNA);
            
            IF RET_MCOL(WS_COUNTER).CD_LIGACAO <> 'SEM' THEN
                WS_XCOUNT := WS_XCOUNT + 1;
                WS_PERC_COL := RET_COLUNA;
                DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_XCOUNT, RET_COLUNA);
            END IF;

            IF FUN.GETPROP(PRM_OBJETO,'HIDDEN') = 1 THEN
                WS_VALOR := TRIM(TO_CHAR(RET_COLUNA,'99999999999'));
			ELSE
				WS_VALOR := '';
			END IF;

            CASE WS_FIND_COL
                WHEN 'AC' THEN WS_II := '001';
                WHEN 'AL' THEN WS_II := '002';
                WHEN 'AP' THEN WS_II := '003';
                WHEN 'AM' THEN WS_II := '004';
                WHEN 'BA' THEN WS_II := '005';
                WHEN 'CE' THEN WS_II := '006';
                WHEN 'DF' THEN WS_II := '007';
                WHEN 'ES' THEN WS_II := '008';
                WHEN 'GO' THEN WS_II := '009';
                WHEN 'MA' THEN WS_II := '010';
                WHEN 'MT' THEN WS_II := '011';
                WHEN 'MS' THEN WS_II := '012';
                WHEN 'MG' THEN WS_II := '013';
                WHEN 'PA' THEN WS_II := '014';
                WHEN 'PB' THEN WS_II := '015';
                WHEN 'PR' THEN WS_II := '016';
                WHEN 'PE' THEN WS_II := '017';
                WHEN 'PI' THEN WS_II := '018';
                WHEN 'RJ' THEN WS_II := '019';
                WHEN 'RN' THEN WS_II := '020';
                WHEN 'RS' THEN WS_II := '021';
                WHEN 'RO' THEN WS_II := '022';
                WHEN 'RR' THEN WS_II := '023';
                WHEN 'SC' THEN WS_II := '024';
                WHEN 'SP' THEN WS_II := '025';
                WHEN 'SE' THEN WS_II := '026';
                WHEN 'TO' THEN WS_II := '027';
                ELSE WS_II := '*';
            END CASE;
	
            SELECT COUNT(*) INTO WS_GOCOUNT FROM GOTO_OBJETO WHERE CD_OBJETO = PRM_OBJETO AND CD_OBJETO_GO NOT IN ( SELECT CD_OBJETO FROM OBJECT_RESTRICTION WHERE USUARIO = GBL.GETUSUARIO );
            SELECT COUNT(*) INTO WS_COUNT FROM FILTROS WHERE TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND TP_FILTRO = 'objeto' AND TRIM(CD_OBJETO) IN (TRIM(PRM_OBJETO)) AND TRIM(CD_USUARIO)  = 'DWU' AND CONDICAO <> 'NOFLOAT';

		    WS_FIND_COL := FUN.CHECK_VALUE(WS_FIND_COL);
		
            IF WS_GOCOUNT = 1 THEN
                
                IF WS_COUNT > 0 THEN
                    SELECT CD_OBJETO_GO||WS_COLUNA||WS_FIND_COL||'|'||PRM_OBJETO||'|'||PRM_SCREEN||'|'||(SELECT RTRIM(CD_COLUNA)||'|'||DECODE(RTRIM(CONDICAO),'IGUAL','$[IGUAL]','DIFERENTE','$[DIFERENTE]','MAIOR','$[MAIOR]','MENOR','$[MENOR]','MAIOROUIGUAL','$[MAIOROUIGUAL]','MENOROUIGUAL','$[MENOROUIGUAL]','LIKE','$[LIKE]','NOTLIKE','$[NOTLIKE]','$[IGUAL]')||RTRIM(CONTEUDO) AS COLUNA FROM FILTROS WHERE TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND TP_FILTRO = 'objeto' AND TRIM(CD_OBJETO) IN (TRIM(PRM_OBJETO)) AND TRIM(CD_USUARIO)  = 'DWU' AND CONDICAO <> 'NOFLOAT') INTO WS_GOOBJETO FROM GOTO_OBJETO WHERE CD_OBJETO = PRM_OBJETO AND CD_OBJETO_GO NOT IN ( SELECT CD_OBJETO FROM OBJECT_RESTRICTION WHERE USUARIO = GBL.GETUSUARIO );
                ELSE
                    SELECT CD_OBJETO_GO||WS_COLUNA||WS_FIND_COL||'|'||PRM_OBJETO||'|'||PRM_SCREEN INTO WS_GOOBJETO FROM GOTO_OBJETO WHERE CD_OBJETO = PRM_OBJETO AND CD_OBJETO_GO NOT IN ( SELECT CD_OBJETO FROM OBJECT_RESTRICTION WHERE USUARIO = GBL.GETUSUARIO );
                END IF;
                
                WS_GOOBJETO := REPLACE(WS_GOOBJETO, CHR(39), '$[QUOTE]');
                WS_GOOBJETO := REPLACE(WS_GOOBJETO, CHR(34), '$[DQUOTE]');
                
                WS_RETORNO := WS_RETORNO||'<entity color="5BA6D7" id="'||WS_II||'" value="'||WS_VALOR||'" link="JavaScript:showview('''||WS_GOOBJETO||'''); " ></entity> '||CHR(13);
            ELSIF WS_GOCOUNT > 1 THEN
                IF WS_COUNT > 0 THEN
                    SELECT WS_COLUNA||WS_FIND_COL||'|'||(SELECT RTRIM(CD_COLUNA)||'|'||DECODE(RTRIM(CONDICAO),'IGUAL','$[IGUAL]','DIFERENTE','$[DIFERENTE]','MAIOR','$[MAIOR]','MENOR','$[MENOR]','MAIOROUIGUAL','$[MAIOROUIGUAL]','MENOROUIGUAL','$[MENOROUIGUAL]','LIKE','$[LIKE]','NOTLIKE','$[NOTLIKE]','$[IGUAL]')||RTRIM(CONTEUDO) AS COLUNA FROM FILTROS WHERE TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND TP_FILTRO = 'objeto' AND TRIM(CD_OBJETO) IN (TRIM(PRM_OBJETO)) AND TRIM(CD_USUARIO)  = 'DWU' AND CONDICAO <> 'NOFLOAT') INTO WS_GOOBJETO FROM GOTO_OBJETO WHERE CD_OBJETO = PRM_OBJETO AND CD_OBJETO_GO NOT IN ( SELECT CD_OBJETO FROM OBJECT_RESTRICTION WHERE USUARIO = GBL.GETUSUARIO ) AND ROWNUM = 1;
                ELSE
                    SELECT WS_COLUNA||WS_FIND_COL INTO WS_GOOBJETO FROM GOTO_OBJETO WHERE CD_OBJETO = PRM_OBJETO AND CD_OBJETO_GO NOT IN ( SELECT CD_OBJETO FROM OBJECT_RESTRICTION WHERE USUARIO = GBL.GETUSUARIO ) AND ROWNUM = 1;
                END IF;
                
                WS_GOOBJETO := REPLACE(WS_GOOBJETO, CHR(39), '$[QUOTE]');
                WS_GOOBJETO := REPLACE(WS_GOOBJETO, CHR(34), '$[DQUOTE]');
                
                WS_RETORNO := WS_RETORNO||'<entity color="5BA6D7" id="'||WS_II||'" value="'||WS_VALOR||'" data-valor="'||PRM_OBJETO||''||REPLACE(WS_GOOBJETO, '%', '%25')||'" id="'||PRM_OBJETO||'_linha_'||WS_COUNTL||'" link="JavaScript: isJavaScriptCall=true; showview2('''||WS_II||''');" ></entity> '||CHR(13);
            ELSE
                WS_RETORNO := WS_RETORNO||'<entity color="5BA6D7" id="'||WS_II||'" value="'||WS_VALOR||'" ></entity> '||CHR(13);
            END IF;

        END LOOP;
    END IF;

DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);


WS_RETORNO := WS_RETORNO||CHR(13)||'</data></map>';

RETURN(WS_RETORNO);

EXCEPTION
WHEN OTHERS THEN
    INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - MAPOUT', GBL.GETUSUARIO, 'ERRO');
    COMMIT;
END MAPOUT;

FUNCTION VPIPE_PAR ( PRM_ENTRADA VARCHAR ) RETURN TAB_PARAMETROS PIPELINED AS

   WS_BINDN      NUMBER;
   WS_TEXTO      LONG;
   WS_NM_VAR     LONG;
   WS_CONDICAO   LONG;
   WS_FLAG       CHAR(1);
   WS_STEP       INTEGER;
   WS_P1         VARCHAR2(4000);

BEGIN









   WS_FLAG  := 'N';
   WS_BINDN := 0;
   WS_TEXTO := PRM_ENTRADA;
   WS_STEP  := 0;

   LOOP
       IF  WS_FLAG = 'Y' THEN
           EXIT;
       END IF;

       IF  NVL(INSTR(WS_TEXTO,'|'),0) = 0 THEN
           WS_FLAG  := 'Y';
           WS_NM_VAR := WS_TEXTO;
       ELSE
           WS_NM_VAR := SUBSTR(WS_TEXTO, 1 ,INSTR(WS_TEXTO,'|')-1);
           WS_TEXTO := SUBSTR(WS_TEXTO, LENGTH(WS_NM_VAR||'|')+1, LENGTH(WS_TEXTO));
       END IF;

        WS_BINDN := WS_BINDN + 1;
	    IF  WS_STEP = 1 THEN
			SELECT DECODE(SUBSTR(WS_NM_VAR,1,2),'$[',DECODE(UPPER(SUBSTR(WS_NM_VAR,3,INSTR(WS_NM_VAR,']')-3)),'IGUAL','IGUAL','DIFERENTE','DIFERENTE','MAIOR','MAIOR','MENOR','MENOR','MAIOROUIGUAL','MAIOROUIGUAL','MENOROUIGUAL','MENOROUIGUAL','LIKE','LIKE','NOTLIKE','NOTLIKE','NULO','NULO','NNULO','NNULO','IGUAL'),'IGUAL') INTO WS_CONDICAO FROM DUAL;
			SELECT DECODE(SUBSTR(WS_NM_VAR,1,2),'$[',SUBSTR(WS_NM_VAR,INSTR(WS_NM_VAR,']')+1,LENGTH(WS_NM_VAR)),WS_NM_VAR) INTO WS_NM_VAR FROM DUAL;

			PIPE ROW (GER_PARAMETROS (TRIM(WS_P1), REPLACE(TRIM(WS_NM_VAR), '$[CONCAT]', '||'), TRIM(WS_CONDICAO)) );
			WS_STEP := 0;
		ELSE
			WS_P1   := WS_NM_VAR;
			WS_STEP := 1;
		END IF;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      PIPE ROW(GER_PARAMETROS('=RET_LIST','XXX',''));

END VPIPE_PAR;


FUNCTION SHOW_FILTROS ( PRM_CONDICOES  VARCHAR2 DEFAULT NULL,
					    PRM_CURSOR    NUMBER   DEFAULT 0,
					    PRM_TIPO  VARCHAR2 DEFAULT 'ATIVO',
					    PRM_OBJETO  VARCHAR2 DEFAULT NULL,
					    PRM_MICRO_VISAO  VARCHAR2 DEFAULT NULL,
					    PRM_SCREEN VARCHAR2 DEFAULT NULL,
                        PRM_USUARIO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

		 CURSOR CRS_FILTROG(PRM_USU VARCHAR2) IS 
		 SELECT INDICE,CD_USUARIO,MICRO_VISAO,CD_COLUNA,CONDICAO,CONTEUDO,LIGACAO, AGRUPADO, MAX(COLOR) AS COR, MAX(TITLE) AS TITULO FROM (
			SELECT 'C'                                    AS INDICE,
					'DWU'                                 AS CD_USUARIO,
					TRIM(PRM_MICRO_VISAO)                 AS MICRO_VISAO,
					DECODE(SUBSTR(TRIM(CD_COLUNA),1,2),'M_',SUBSTR(TRIM(CD_COLUNA),3,LENGTH(TRIM(CD_COLUNA))),TRIM(CD_COLUNA)) AS CD_COLUNA,
					'DIFERENTE'                           AS CONDICAO,
					REPLACE(TRIM(CONTEUDO), '$[NOT]', '') AS CONTEUDO,
					'and'                                 AS LIGACAO,
					''                                    AS AGRUPADO,
					DECODE(FUN.GETPROP(PRM_OBJETO,'FILTRO_FLOAT'), 'S', 'parametro cut', 'parametro') AS COLOR,
					'Filtro de parametro' AS TITLE
			 FROM   FLOAT_FILTER_ITEM
			 WHERE
				  TRIM(CD_USUARIO) = PRM_USU AND
				  TRIM(SCREEN) = TRIM(PRM_SCREEN) AND
				  INSTR(TRIM(CONTEUDO), '$[NOT]') <> 0 AND
                  TRIM(CD_COLUNA) NOT IN (SELECT CD_COLUNA FROM FILTROS WHERE CONDICAO = 'NOFLOAT' AND TP_FILTRO = 'objeto' AND TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND TRIM(CD_OBJETO) = TRIM(PRM_OBJETO)) AND
				  DECODE(SUBSTR(TRIM(CD_COLUNA),1,2),'M_',SUBSTR(TRIM(CD_COLUNA),3,LENGTH(TRIM(CD_COLUNA))),TRIM(CD_COLUNA)) IN ( SELECT TRIM(CD_COLUNA)
				 FROM   MICRO_COLUNA MC
				 WHERE  TRIM(MC.CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO) AND 
                 TRIM(MC.CD_COLUNA) NOT IN (SELECT NVL(TRIM(CD_COLUNA), 'N/A') FROM TABLE(FUN.VPIPE_PAR(PRM_CONDICOES)))				 
				 )  AND
				 LENGTH(TRIM(CONTEUDO)) > 0
				 
		 UNION ALL
			SELECT 'C'                   AS INDICE,
					'DWU'                 AS CD_USUARIO,
					TRIM(PRM_MICRO_VISAO) AS MICRO_VISAO,
					DECODE(SUBSTR(TRIM(CD_COLUNA),1,2),'M_',SUBSTR(TRIM(CD_COLUNA),3,LENGTH(TRIM(CD_COLUNA))),TRIM(CD_COLUNA)) AS CD_COLUNA,
					'IGUAL'               AS CONDICAO,
					TRIM(CONTEUDO)     AS CONTEUDO,
					'and'                 AS LIGACAO,
					''                     AS AGRUPADO,
					DECODE(FUN.GETPROP(PRM_OBJETO,'FILTRO_FLOAT'), 'S', 'parametro cut', 'parametro') AS COLOR,
					'Filtro de parametro' AS TITLE
			 FROM   FLOAT_FILTER_ITEM
			 WHERE
				  TRIM(CD_USUARIO) = PRM_USU AND
				  TRIM(SCREEN) = TRIM(PRM_SCREEN) AND
				  INSTR(TRIM(CONTEUDO), '$[NOT]') = 0 AND
                  TRIM(CD_COLUNA) NOT IN (SELECT CD_COLUNA FROM FILTROS WHERE CONDICAO = 'NOFLOAT' AND TP_FILTRO = 'objeto' AND TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND TRIM(CD_OBJETO) = TRIM(PRM_OBJETO)) AND
				  DECODE(SUBSTR(TRIM(CD_COLUNA),1,2),'M_',SUBSTR(TRIM(CD_COLUNA),3,LENGTH(TRIM(CD_COLUNA))),TRIM(CD_COLUNA)) IN ( SELECT TRIM(CD_COLUNA)
				 FROM   MICRO_COLUNA MC
				 WHERE  TRIM(MC.CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO) AND 
                 TRIM(MC.CD_COLUNA) NOT IN (SELECT NVL(TRIM(CD_COLUNA), 'N/A') FROM TABLE(FUN.VPIPE_PAR(PRM_CONDICOES)))				 
				 )  AND
				 LENGTH(TRIM(CONTEUDO)) > 0
				 
		 UNION ALL
	         SELECT 
			 'C'                   AS INDICE,
	         'DWU' AS CD_USUARIO,
	         TRIM(PRM_MICRO_VISAO) AS MICRO_VISAO,
	         TRIM(CD_COLUNA)       AS CD_COLUNA,
	         CD_CONDICAO               AS CONDICAO,
	         TRIM(CD_CONTEUDO)     AS CONTEUDO,
	         'and'                 AS LIGACAO,
			 ''                     AS AGRUPADO,
		     DECODE(FUN.GETPROP(PRM_OBJETO,'FILTRO_DRILL'), 'S', 'drill cut','drill') AS COLOR,
			 'Filtro da drill' AS TITLE
	          FROM TABLE(FUN.VPIPE_PAR(PRM_CONDICOES)) PC WHERE CD_COLUNA <> '1' AND 
              TRIM(CD_COLUNA) IN (SELECT TRIM(CD_COLUNA) FROM MICRO_COLUNA WHERE TRIM(CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO) UNION ALL SELECT TRIM(CD_COLUNA) FROM MICRO_VISAO_FPAR WHERE  TRIM(CD_MICRO_VISAO)=TRIM(PRM_MICRO_VISAO)) AND
			  TRIM(CD_COLUNA)||TRIM(CD_CONTEUDO) NOT IN (
			      SELECT NOF.CD_COLUNA||NOF.CONTEUDO FROM  FILTROS NOF
				  WHERE  TRIM(NOF.MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND 
				  TRIM(NOF.CONDICAO) = 'NOFILTER' AND 
                  TRIM(NOF.CONTEUDO) = TRIM(PC.CD_CONTEUDO) AND 
				  TRIM(NOF.CD_OBJETO) = TRIM(PRM_OBJETO)
			  )
         UNION ALL
			SELECT	'C'             AS INDICE,
				RTRIM(CD_USUARIO)	AS CD_USUARIO,
				RTRIM(MICRO_VISAO)	AS MICRO_VISAO,
				RTRIM(CD_COLUNA)	AS CD_COLUNA,
				RTRIM(CONDICAO)		AS CONDICAO,
				RTRIM(CONTEUDO)		AS CONTEUDO,
				RTRIM(LIGACAO)		AS LIGACAO,
				''  AS AGRUPADO,
	            'usuario' AS COLOR,
	            'Filtro do usu&aacute;rio' AS TITLE
			FROM 	FILTROS T1
			WHERE	TRIM(MICRO_VISAO) = RTRIM(PRM_MICRO_VISAO) AND
			TP_FILTRO   = 'geral' AND
            ST_AGRUPADO = 'N' AND 
            (RTRIM(CD_USUARIO)  IN (PRM_USU, 'DWU') OR TRIM(CD_USUARIO) IN (SELECT CD_GROUP FROM GUSERS_ITENS WHERE CD_USUARIO = PRM_USU))

			AND LENGTH(TRIM(CONTEUDO)) > 0
			UNION
			SELECT	'C'             AS INDICE,
				TRIM(CD_USUARIO)	AS CD_USUARIO,
				TRIM(MICRO_VISAO)	AS MICRO_VISAO,
				TRIM(CD_COLUNA)	    AS CD_COLUNA,
				TRIM(CONDICAO)		AS CONDICAO,
				TRIM(CONTEUDO)		AS CONTEUDO,
				TRIM(LIGACAO)		AS LIGACAO,
				DECODE(RTRIM(ST_AGRUPADO), 'S', '(agrupado)', 'N', '', '')  AS AGRUPADO,
			DECODE(TRIM(CD_OBJETO), TRIM(PRM_SCREEN), DECODE(FUN.GETPROP(PRM_OBJETO,'FILTRO_TELA'), 'S', 'objeto cut', 'objeto'), 'objeto') AS COLOR,
			'Filtro da tela ou do objeto' AS TITLE
			FROM 	FILTROS
			WHERE	TRIM(MICRO_VISAO) = TRIM(PRM_MICRO_VISAO)  AND
			TP_FILTRO = 'objeto' AND
            ( TRIM(CD_OBJETO) = TRIM(PRM_OBJETO) OR (TRIM(CD_OBJETO) = TRIM(PRM_SCREEN) AND (NVL(FUN.GETPROP(TRIM(PRM_OBJETO),'FILTRO'), 'N/A')<>'ISOLADO' AND NVL(FUN.GETPROP(TRIM(PRM_OBJETO),'FILTRO'), 'N/A') <> 'COM CORTE')) )
			 AND
			TRIM(CD_USUARIO)  = 'DWU' 
			AND LENGTH(TRIM(CONTEUDO)) > 0  AND 
            CONDICAO <> 'NOFLOAT' AND
			CONDICAO <> 'NOFILTER'
			
			UNION ALL
			
			SELECT
			    'C'                   AS INDICE,
				RTRIM(CD_USUARIO)	AS CD_USUARIO,
				RTRIM(MICRO_VISAO)	AS MICRO_VISAO,
				RTRIM(CD_COLUNA)	AS CD_COLUNA,
				RTRIM(CONDICAO)		AS CONDICAO,
				RTRIM(CONTEUDO)		AS CONTEUDO,
				RTRIM(LIGACAO)		AS LIGACAO,
				DECODE(RTRIM(ST_AGRUPADO), 'S', '(agrupado)', 'N', '', '')  AS AGRUPADO,
			'ignorado' AS COLOR,
			'Filtro ignorado' AS TITLE
			FROM 	FILTROS
			WHERE	RTRIM(MICRO_VISAO) = RTRIM(PRM_MICRO_VISAO)  AND
            ( RTRIM(CD_OBJETO) = TRIM(PRM_OBJETO) OR (RTRIM(CD_OBJETO) = TRIM(PRM_SCREEN)) )
			  AND
			  TRIM(CD_USUARIO)  = 'DWU' 
			  AND LENGTH(TRIM(CONTEUDO)) > 0  AND 
			  CONDICAO = 'NOFILTER'
            )
			GROUP BY INDICE,CD_USUARIO,MICRO_VISAO,CD_COLUNA,CONDICAO,CONTEUDO,LIGACAO, AGRUPADO
            ORDER BY COR, CD_USUARIO, MICRO_VISAO, CD_COLUNA, CONDICAO, CONTEUDO;
			
			






    WS_FILTROG CRS_FILTROG%ROWTYPE;

    WS_BINDN  NUMBER;
    WS_DISTINTOS  LONG;
    WS_TEXTO  LONG;
    WS_TEXTOT  LONG;
    WS_NM_VAR  LONG;
    WS_CT_VAR  LONG;
    WS_NULL   LONG;
    WS_RETORNO  LONG;
    WS_CONTEUDO     VARCHAR2(32000);
    WS_TCONT        VARCHAR2(32000);
    WS_CONDICAO     VARCHAR2(32000);
    WS_COL_ANT      VARCHAR2(32000) := '';
    WS_CONDICAO_ANT VARCHAR2(32000) := '';

    WS_CURSOR INTEGER;
    WS_LINHAS INTEGER;

    WS_CALCULADO VARCHAR2(32000);
    WS_SQL       VARCHAR2(32000);

    CRLF VARCHAR2( 2 ):= CHR( 13 ) || CHR( 10 );
 
    WS_FILTRO  VARCHAR2(32000);
    WS_COLOR   VARCHAR2(200) := '';
    WS_USUARIO VARCHAR2(80);

BEGIN

    WS_USUARIO := PRM_USUARIO;

    IF NVL(WS_USUARIO, 'N/A') = 'N/A' THEN
        WS_USUARIO := GBL.GETUSUARIO;
    END IF;

    WS_BINDN := 1;
    WS_TEXTO := PRM_CONDICOES;

 OPEN CRS_FILTROG(WS_USUARIO);
 LOOP
    FETCH CRS_FILTROG INTO WS_FILTROG;
    EXIT WHEN CRS_FILTROG%NOTFOUND;

    WS_TCONT := WS_FILTROG.CONTEUDO;

    IF SUBSTR(WS_TCONT,1,2) = '$[' THEN
        WS_TCONT := FUN.GPARAMETRO(WS_TCONT, PRM_SCREEN => PRM_SCREEN);
    END IF;

    IF SUBSTR(WS_TCONT,1,2) = '#[' THEN
        WS_TCONT := FUN.RET_VAR(WS_TCONT, WS_USUARIO);
    END IF;

    IF UPPER(SUBSTR(WS_TCONT,1,5)) = 'EXEC=' THEN
        WS_TCONT := FUN.XEXEC(WS_TCONT, PRM_SCREEN);
    END IF;

    CASE WS_FILTROG.CONDICAO
    WHEN 'IGUAL' THEN
        WS_CONDICAO := FUN.LANG('Igual a');
    WHEN 'DIFERENTE' THEN
        WS_CONDICAO := FUN.LANG('Diferente de');
    WHEN 'MAIOR' THEN
        WS_CONDICAO := FUN.LANG('Maior que');
    WHEN 'MENOR' THEN
        WS_CONDICAO := FUN.LANG('Menor que');
    WHEN 'MAIOROUIGUAL' THEN
        WS_CONDICAO := FUN.LANG('Maior ou igual a');
    WHEN 'MENOROUIGUAL' THEN
        WS_CONDICAO := FUN.LANG('Menor ou igual a');
    WHEN 'LIKE' THEN
        WS_CONDICAO := FUN.LANG('Semelhante a');
    ELSE
        WS_CONDICAO := '***';
    END CASE;

	WS_COLOR := WS_FILTROG.COR;
	
	IF WS_CONDICAO_ANT = WS_CONDICAO THEN
	    IF WS_COL_ANT = WS_FILTROG.CD_COLUNA THEN
	        WS_FILTRO := WS_FILTRO||FUN.COL_NAME(WS_FILTROG.CD_COLUNA, WS_FILTROG.MICRO_VISAO, WS_CONDICAO, WS_TCONT, WS_FILTROG.COR, FUN.LANG(WS_FILTROG.TITULO), TRUE, WS_FILTROG.AGRUPADO);
	    ELSE
	        WS_FILTRO := WS_FILTRO||FUN.COL_NAME(WS_FILTROG.CD_COLUNA, WS_FILTROG.MICRO_VISAO, WS_CONDICAO, WS_TCONT, WS_FILTROG.COR, FUN.LANG(WS_FILTROG.TITULO), FALSE, WS_FILTROG.AGRUPADO);
	    END IF;
	ELSE
	    WS_FILTRO := WS_FILTRO||FUN.COL_NAME(WS_FILTROG.CD_COLUNA, WS_FILTROG.MICRO_VISAO, WS_CONDICAO, WS_TCONT, WS_FILTROG.COR, FUN.LANG(WS_FILTROG.TITULO), FALSE, WS_FILTROG.AGRUPADO);
	END IF;
    WS_BINDN := WS_BINDN + 1;

	WS_CONDICAO_ANT := WS_CONDICAO;
	WS_COL_ANT := WS_FILTROG.CD_COLUNA;

 END LOOP;
 CLOSE CRS_FILTROG;

  RETURN (WS_FILTRO);

EXCEPTION
 WHEN OTHERS THEN
  HTP.P(SQLERRM||'=SHOW_FILTROS');

END SHOW_FILTROS;

FUNCTION SHOW_DESTAQUES ( PRM_CONDICOES   VARCHAR2 DEFAULT NULL,
					      PRM_CURSOR      NUMBER   DEFAULT 0,
					      PRM_TIPO        VARCHAR2 DEFAULT 'ATIVO',
					      PRM_OBJETO      VARCHAR2 DEFAULT NULL,
					      PRM_MICRO_VISAO VARCHAR2 DEFAULT NULL,
					      PRM_SCREEN      VARCHAR2 DEFAULT NULL,
                          PRM_USUARIO     VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

		CURSOR CRS_DESTAQUES(PRM_USU VARCHAR2) IS
		SELECT CD_COLUNA, CONDICAO, CONTEUDO, COR_FUNDO, COR_FONTE, TIPO_DESTAQUE, 
		(SELECT CD_MICRO_VISAO FROM PONTO_AVALIACAO WHERE CD_PONTO = PRM_OBJETO) AS MICRO_VISAO,
		CD_DESTAQUE
		FROM DESTAQUE T1
		WHERE (UPPER(TRIM(T1.CD_USUARIO)) = PRM_USU OR UPPER(TRIM(T1.CD_USUARIO)) = 'DWU' OR UPPER(TRIM(T1.CD_USUARIO)) IN (SELECT UPPER(TRIM(CD_GROUP)) FROM GUSERS_ITENS T2 WHERE T2.CD_USUARIO = PRM_USU)) AND CD_OBJETO = PRM_OBJETO;
		
		WS_DESTAQUE CRS_DESTAQUES%ROWTYPE;

		WS_TCONT        VARCHAR2(800);
		WS_CONDICAO     VARCHAR2(800);
		WS_COL_ANT      VARCHAR2(800) := '';
		WS_CONDICAO_ANT VARCHAR2(800) := '';
		WS_FILTRO       VARCHAR2(18000);
		WS_BINDN        NUMBER;
        WS_USUARIO      VARCHAR2(80);
BEGIN

 WS_USUARIO := PRM_USUARIO;

 IF NVL(WS_USUARIO, 'N/A') = 'N/A' THEN
     WS_USUARIO := GBL.GETUSUARIO;
 END IF;

 OPEN CRS_DESTAQUES(WS_USUARIO);
 LOOP
    FETCH CRS_DESTAQUES INTO WS_DESTAQUE;
    EXIT WHEN CRS_DESTAQUES%NOTFOUND;

    WS_TCONT := WS_DESTAQUE.CONTEUDO;

    IF SUBSTR(WS_TCONT,1,2) = '$[' THEN
        WS_TCONT := FUN.GPARAMETRO(WS_TCONT, PRM_SCREEN => PRM_SCREEN);
    END IF;

    IF SUBSTR(WS_TCONT,1,2) = '#[' THEN
        WS_TCONT := FUN.RET_VAR(WS_TCONT, WS_USUARIO);
    END IF;

    IF UPPER(SUBSTR(WS_TCONT,1,5)) = 'EXEC=' THEN
        WS_TCONT := FUN.XEXEC(WS_TCONT, PRM_SCREEN);
    END IF;

    CASE WS_DESTAQUE.CONDICAO
    WHEN 'IGUAL' THEN
        WS_CONDICAO := FUN.LANG('Igual a');
    WHEN 'DIFERENTE' THEN
        WS_CONDICAO := FUN.LANG('Diferente de');
    WHEN 'MAIOR' THEN
        WS_CONDICAO := FUN.LANG('Maior que');
    WHEN 'MENOR' THEN
        WS_CONDICAO := FUN.LANG('Menor que');
    WHEN 'MAIOROUIGUAL' THEN
        WS_CONDICAO := FUN.LANG('Maior ou igual a');
    WHEN 'MENOROUIGUAL' THEN
        WS_CONDICAO := FUN.LANG('Menor ou igual a');
    WHEN 'LIKE' THEN
        WS_CONDICAO := FUN.LANG('Semelhante a');
    ELSE
        WS_CONDICAO := '***';
    END CASE;

	
	IF WS_CONDICAO_ANT = WS_CONDICAO THEN
	    IF WS_COL_ANT = WS_DESTAQUE.CD_COLUNA THEN
	        WS_FILTRO := WS_FILTRO||FUN.COL_NAME(WS_DESTAQUE.CD_COLUNA, WS_DESTAQUE.MICRO_VISAO, WS_CONDICAO, WS_TCONT, 'destaque', WS_DESTAQUE.CD_DESTAQUE, FALSE, '');
	    ELSE
	        WS_FILTRO := WS_FILTRO||FUN.COL_NAME(WS_DESTAQUE.CD_COLUNA, WS_DESTAQUE.MICRO_VISAO, WS_CONDICAO, WS_TCONT, 'destaque', WS_DESTAQUE.CD_DESTAQUE, FALSE, '');
	    END IF;
	ELSE
	        WS_FILTRO := WS_FILTRO||FUN.COL_NAME(WS_DESTAQUE.CD_COLUNA, WS_DESTAQUE.MICRO_VISAO, WS_CONDICAO, WS_TCONT, 'destaque', WS_DESTAQUE.CD_DESTAQUE, FALSE, '');
	END IF;
    WS_BINDN := WS_BINDN + 1;

	WS_CONDICAO_ANT := WS_CONDICAO;
	WS_COL_ANT := WS_DESTAQUE.CD_COLUNA;
	
 END LOOP;
 CLOSE CRS_DESTAQUES;

  RETURN (WS_FILTRO);

EXCEPTION
 WHEN OTHERS THEN
  HTP.P(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||'=show_destaques');

END SHOW_DESTAQUES;

FUNCTION PUT_VAR ( PRM_VARIAVEL VARCHAR2 DEFAULT NULL,
                   PRM_CONTEUDO VARCHAR2 DEFAULT NULL )  RETURN VARCHAR2 AS
											  
	WS_COUNT NUMBER;
BEGIN

    BEGIN
        SELECT COUNT(*) INTO WS_COUNT FROM VAR_CONTEUDO WHERE VARIAVEL = PRM_VARIAVEL;
		IF WS_COUNT = 0 THEN
		    INSERT INTO VAR_CONTEUDO VALUES('DWU', PRM_VARIAVEL, SYSDATE, PRM_CONTEUDO, 'N');
            RETURN('ok');
		ELSE
		    UPDATE VAR_CONTEUDO 
			SET CONTEUDO = PRM_CONTEUDO
			WHERE VARIAVEL = PRM_VARIAVEL;
		END IF;
    EXCEPTION WHEN OTHERS THEN
        RETURN(SQLERRM);
	END;
END PUT_VAR;


FUNCTION CHECK_SYS  RETURN VARCHAR2 AS

        WS_CHECK      VARCHAR2(40);
        WS_CHECK1     VARCHAR2(40);
        WS_CHECK2     VARCHAR2(40);
BEGIN

BEGIN
     BEGIN
        SELECT POSX INTO WS_CHECK1
        FROM   OBJECT_LOCATION
        WHERE  OWNER    ='DWU' AND
               NAVEGADOR='DEFAULT' AND
               OBJECT_ID='CONFIG';
        IF  WS_CHECK1 = '12px' THEN
            WS_CHECK1 := 'OPEN';
        ELSIF WS_CHECK1 = '13px' THEN
            WS_CHECK1 := 'BLOCK';
		ELSE
		    WS_CHECK1 := 'LOCKED';
        END IF;
     EXCEPTION
        WHEN OTHERS THEN
            WS_CHECK1 := 'LOCKED';
     END;

     BEGIN
        SELECT CONTEUDO INTO WS_CHECK2
        FROM   VAR_CONTEUDO
        WHERE  USUARIO ='DWU' AND
               VARIAVEL='LOCK_SYS';
        IF  WS_CHECK2 = 'OFF' THEN
            WS_CHECK2 := 'OPEN';
        ELSE
            WS_CHECK2 := 'LOCKED';
        END IF;
     EXCEPTION
        WHEN OTHERS THEN
             WS_CHECK2 := 'LOCKED';
     END;

EXCEPTION
     WHEN OTHERS THEN
          WS_CHECK1 := 'LOCKED';
          WS_CHECK2 := 'LOCKED';
END;
     IF  WS_CHECK1 = 'OPEN' AND WS_CHECK2 = 'OPEN' THEN
         WS_CHECK := 'OPEN';
     ELSE
	    IF WS_CHECK1 = 'BLOCK' THEN
		    WS_CHECK := 'BLOCK';
		ELSE
            WS_CHECK := 'LOCKED';
	    END IF;
     END IF;
     RETURN(WS_CHECK);

END CHECK_SYS;


FUNCTION RCONDICAO ( PRM_VARIAVEL VARCHAR) RETURN CHAR AS

        WS_RETORNO   VARCHAR2(50);

BEGIN
     CASE UPPER(PRM_VARIAVEL)
      WHEN 'IGUAL' THEN
           WS_RETORNO := '=';
      WHEN 'DIFERENTE' THEN
           WS_RETORNO := '<>';
      WHEN 'MAIOR' THEN
           WS_RETORNO := '>';
      WHEN 'MENOR' THEN
           WS_RETORNO := '<';
      WHEN 'MAIOROUIGUAL' THEN
           WS_RETORNO := '>=';
      WHEN 'MENOROUIGUAL' THEN
           WS_RETORNO := '<=';
      WHEN 'LIKE' THEN
           WS_RETORNO := ' like ';
      WHEN 'NOTLIKE' THEN
           WS_RETORNO := ' not like ';
      ELSE
           WS_RETORNO := '***';
     END CASE;

     RETURN (TRIM(WS_RETORNO));

END RCONDICAO;

FUNCTION DCONDICAO ( PRM_VARIAVEL VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

    WS_RETORNO   VARCHAR2(40);

BEGIN
    CASE UPPER(PRM_VARIAVEL)
    WHEN 'IGUAL' THEN
        WS_RETORNO := 'Igual a';
    WHEN 'DIFERENTE' THEN
        WS_RETORNO := 'Diferente de';
    WHEN 'MAIOR' THEN
        WS_RETORNO := 'Maior que';
    WHEN 'MENOR' THEN
        WS_RETORNO := 'Menor que';
    WHEN 'MAIOROUIGUAL' THEN
        WS_RETORNO := 'Maior ou igual a';
    WHEN 'MENOROUIGUAL' THEN
        WS_RETORNO := 'Menor ou igual a';
    WHEN 'LIKE' THEN
        WS_RETORNO := 'Semelhante a(like)';
    WHEN 'NOTLIKE' THEN
        WS_RETORNO := 'Diferente de(not like)';
    WHEN 'NOFLOAT' THEN
        WS_RETORNO := 'Ignorar float';     
    ELSE
        WS_RETORNO := '***';
    END CASE;

     RETURN (TRIM(WS_RETORNO));

END DCONDICAO;

FUNCTION CONVERT_PAR  ( PRM_VARIAVEL  VARCHAR2,
                        PRM_ASPAS     VARCHAR2 DEFAULT NULL,
						PRM_SCREEN    VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

        WS_RETORNO   LONG;

BEGIN

    WS_RETORNO := PRM_VARIAVEL;

     IF  SUBSTR(PRM_VARIAVEL,1,2) = '$[' THEN
         WS_RETORNO := FUN.GPARAMETRO(PRM_VARIAVEL, PRM_SCREEN => PRM_SCREEN);
     END IF;

     IF  SUBSTR(PRM_VARIAVEL,1,2) = '@[' THEN
         WS_RETORNO := FUN.GVALOR(PRM_VARIAVEL, PRM_SCREEN => PRM_SCREEN);
     END IF;

     IF  UPPER(SUBSTR(PRM_VARIAVEL,1,5)) = 'EXEC=' THEN
         WS_RETORNO := FUN.XEXEC(PRM_VARIAVEL, PRM_SCREEN);
     END IF;
     
     RETURN (PRM_ASPAS||TRIM(WS_RETORNO)||PRM_ASPAS);
EXCEPTION WHEN OTHERS THEN
    RETURN PRM_VARIAVEL;
END CONVERT_PAR;

FUNCTION SUBVAR (  PRM_TEXTO VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 AS

 WS_TEXTO VARCHAR2(3000);
 WS_FUNCAO VARCHAR2(3000);
 WS_VAR  VARCHAR2(1000);
 WS_AGRUPADOR VARCHAR2(20);
 WS_TIPO  VARCHAR2(1);

 WS_COUNT NUMBER;

BEGIN

WS_COUNT := 0;
WS_TEXTO := PRM_TEXTO||'#FIM';
WS_FUNCAO := '';

LOOP
    WS_COUNT := WS_COUNT + 1;
    IF  SUBSTR(WS_TEXTO,WS_COUNT,4)='#FIM' THEN
        EXIT;
    END IF;

    IF  SUBSTR(WS_TEXTO,WS_COUNT,1) IN ('$') THEN
        WS_TIPO := SUBSTR(WS_TEXTO,WS_COUNT,1);
        WS_VAR  := '';
        WS_COUNT := WS_COUNT + 1;
        IF  SUBSTR(WS_TEXTO,WS_COUNT,1)<>'[' THEN
            WS_FUNCAO := WS_FUNCAO||SUBSTR(WS_TEXTO,(WS_COUNT-1),1);
            WS_FUNCAO := WS_FUNCAO||SUBSTR(WS_TEXTO, WS_COUNT,   1);
        ELSE
            LOOP
               WS_COUNT  := WS_COUNT + 1;
               IF  SUBSTR(WS_TEXTO,WS_COUNT,1)=']' THEN
                   IF  WS_TIPO = '$' THEN
                       WS_FUNCAO := WS_FUNCAO||CHR(39)||'||'||WS_VAR||'||'||CHR(39);
                       EXIT;
                   END IF;
               END IF;
               WS_VAR := WS_VAR||SUBSTR(WS_TEXTO,WS_COUNT,1);
            END LOOP;
 END IF;
    ELSE
        WS_FUNCAO := WS_FUNCAO||SUBSTR(WS_TEXTO,WS_COUNT,1);
    END IF;

END LOOP;

RETURN(CHR(39)||WS_FUNCAO||CHR(39));

END SUBVAR;


  

FUNCTION CHECK_NETWALL ( PRM_USER VARCHAR2 DEFAULT NULL ) RETURN BOOLEAN AS

    CURSOR CRS_NETWALL IS
    SELECT USUARIO, NOME_REGRA, TIPO_REGRA, NET_ADDRESS, HR_INICIO, HR_FINAL, DIA_SEMANA, DT_REGRA FROM USER_NETWALL
    WHERE TRIM(USUARIO) = UPPER(TRIM(PRM_USER))
    ORDER BY TIPO_REGRA DESC;

    WS_NETWALL    CRS_NETWALL%ROWTYPE;

    WS_DIA_SEMANA      CHAR(1);
    WS_HORARIO         INTEGER;
    WS_REMOTE_ADR      VARCHAR2(39);
    WS_CHECK_PASS      BOOLEAN := FALSE;

BEGIN

    WS_DIA_SEMANA := TO_CHAR(SYSDATE,'D');
    WS_HORARIO    := TO_CHAR(SYSDATE,'HH24');
    WS_REMOTE_ADR := TRIM(OWA_UTIL.GET_CGI_ENV('REMOTE_ADDR'));

	OPEN CRS_NETWALL;
		LOOP
			FETCH CRS_NETWALL INTO WS_NETWALL;
			EXIT WHEN CRS_NETWALL%NOTFOUND;

			IF WS_NETWALL.TIPO_REGRA = 'L' THEN
				IF NVL(TRIM(WS_NETWALL.NET_ADDRESS),'NOADDR') = 'NOADDR' OR TRIM(WS_NETWALL.NET_ADDRESS) = SUBSTR(WS_REMOTE_ADR,1,LENGTH(TRIM(WS_NETWALL.NET_ADDRESS))) THEN
                        IF (WS_NETWALL.HR_INICIO=0 AND WS_NETWALL.HR_FINAL=24) OR (WS_HORARIO BETWEEN WS_NETWALL.HR_INICIO AND WS_NETWALL.HR_FINAL) OR (WS_NETWALL.HR_INICIO=99) OR (WS_NETWALL.HR_FINAL=99) THEN
						IF (WS_NETWALL.DIA_SEMANA = 0) OR
							(WS_NETWALL.DIA_SEMANA = WS_DIA_SEMANA) OR
							(WS_NETWALL.DIA_SEMANA = '9' AND WS_DIA_SEMANA IN ('7','1')) OR
							(WS_NETWALL.DIA_SEMANA = '8' AND WS_DIA_SEMANA NOT IN ('7','1')) THEN
							WS_CHECK_PASS := TRUE;
						END IF;
					END IF;
				END IF;
			END IF;

			IF WS_NETWALL.TIPO_REGRA = 'B' THEN
				IF NVL(TRIM(WS_NETWALL.NET_ADDRESS),'NOADDR') = 'NOADDR' OR TRIM(WS_NETWALL.NET_ADDRESS) = SUBSTR(WS_REMOTE_ADR,1,LENGTH(TRIM(WS_NETWALL.NET_ADDRESS))) THEN
                        IF (WS_NETWALL.HR_INICIO=0 AND WS_NETWALL.HR_FINAL=24) OR (WS_HORARIO BETWEEN WS_NETWALL.HR_INICIO AND WS_NETWALL.HR_FINAL) OR (WS_NETWALL.HR_INICIO=99) OR (WS_NETWALL.HR_FINAL=99) THEN
						IF  (WS_NETWALL.DIA_SEMANA = 0) OR
							(WS_NETWALL.DIA_SEMANA = WS_DIA_SEMANA) OR
							(WS_NETWALL.DIA_SEMANA = '9' AND WS_DIA_SEMANA IN ('7','1')) OR
							(WS_NETWALL.DIA_SEMANA = '8' AND WS_DIA_SEMANA NOT IN ('7','1')) THEN
							WS_CHECK_PASS := FALSE;
						END IF;
					END IF;
				END IF;
			END IF;

		END LOOP;
	CLOSE CRS_NETWALL;
		
    RETURN (WS_CHECK_PASS);
 
EXCEPTION WHEN OTHERS THEN
    
	WS_CHECK_PASS := FALSE;
    RETURN (WS_CHECK_PASS);
	
END CHECK_NETWALL;


FUNCTION APPLY_DRE_MASC ( PRM_MASC VARCHAR DEFAULT NULL,
                          PRM_STRING VARCHAR DEFAULT NULL ) RETURN VARCHAR2 AS

    WS_COUNT      NUMBER;
    WS_PSTRING    NUMBER;
    WS_STRING_TMP VARCHAR2(2000) := '';

BEGIN

    WS_COUNT   := 1;
    WS_PSTRING := 1;

    LOOP
        EXIT WHEN WS_COUNT > LENGTH(PRM_MASC) OR
        WS_PSTRING > LENGTH(PRM_STRING) OR
        SUBSTR(PRM_STRING,WS_PSTRING,1) = ' ';

        IF SUBSTR(PRM_MASC,WS_COUNT,1) = '.' THEN
            WS_STRING_TMP := WS_STRING_TMP||'.';
        ELSE
            WS_STRING_TMP := WS_STRING_TMP||SUBSTR(PRM_STRING,WS_PSTRING,1);
            WS_PSTRING := WS_PSTRING + 1;
        END IF;
		
        WS_COUNT := WS_COUNT + 1;

    END LOOP;

 RETURN (WS_STRING_TMP);

EXCEPTION
    
	WHEN OTHERS THEN
    RETURN ('0');

END APPLY_DRE_MASC;


PROCEDURE EXECUTE_NOW ( PRM_COMANDO  VARCHAR2 DEFAULT NULL,
                        PRM_REPEAT  VARCHAR2 DEFAULT  'S' ) AS

    JOB_ID          NUMBER;
    WS_OWNER        VARCHAR2(90);
    WS_NAME         VARCHAR2(90);
    WS_LINE         NUMBER;
    WS_CALLER       VARCHAR2(90);
    WS_COUNT        NUMBER := 0;

BEGIN

    IF PRM_REPEAT = 'N' THEN
	    SELECT COUNT(*) INTO WS_COUNT FROM ALL_JOBS WHERE WHAT = TRIM(PRM_COMANDO)||';';
    END IF;
    
    OWA_UTIL.WHO_CALLED_ME(WS_OWNER, WS_NAME, WS_LINE, WS_CALLER);
	
        IF WS_COUNT = 0 THEN
            DBMS_JOB.SUBMIT(JOB => JOB_ID, WHAT => TRIM(PRM_COMANDO)||';', NEXT_DATE => SYSDATE+((1/1440)/40), INTERVAL => NULL);
            COMMIT;
        END IF;
EXCEPTION WHEN OTHERS THEN
    INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - EXECUTE_NOW', GBL.GETUSUARIO, 'ERRO');
    COMMIT;
END EXECUTE_NOW;


FUNCTION GL_CALCULADA ( PRM_TEXTO        VARCHAR2 DEFAULT NULL,
                        PRM_CD_COLUNA    VARCHAR2 DEFAULT NULL,
                        PRM_VL_AGRUPADOR VARCHAR2 DEFAULT NULL,
						PRM_TABELA       VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS
						
    WS_TEXTO VARCHAR2(3000);
    WS_FUNCAO VARCHAR2(3000);
    WS_VAR  VARCHAR2(1000);
    WS_AGRUPADOR VARCHAR2(20);
    WS_TIPO  VARCHAR2(1);
    WS_COUNT NUMBER;
	WS_FORMULA VARCHAR2(2000);

BEGIN

    WS_COUNT := 0;
    WS_TEXTO := UPPER(PRM_TEXTO)||'#';
    WS_FUNCAO := '';

	LOOP
		WS_COUNT := WS_COUNT + 1;
		IF  SUBSTR(WS_TEXTO,WS_COUNT,1)='#' THEN
			EXIT;
		END IF;

		IF  SUBSTR(PTG_TRANS(WS_TEXTO),WS_COUNT,1) IN (',','_','Q','W','E','R','T','Y','U','I','O','P','A','S','D','F','G','H','J','K','L','Z','X','C','V','B','N','M') THEN
			WS_FUNCAO := WS_FUNCAO||SUBSTR(WS_TEXTO,WS_COUNT,1);
		END IF;

		IF  SUBSTR(WS_TEXTO,WS_COUNT,1) IN ('+','-','/','*','(',')','>','<', CHR(39), '|', '=', ':') THEN
			WS_FUNCAO := WS_FUNCAO||SUBSTR(WS_TEXTO,WS_COUNT,1);
		END IF;

		IF  SUBSTR(WS_TEXTO,WS_COUNT,1) IN ('.','0','1','2','3','4','5','6','7','8','9') THEN
			WS_FUNCAO := WS_FUNCAO||SUBSTR(WS_TEXTO,WS_COUNT,1);
		END IF;

		IF  SUBSTR(WS_TEXTO,WS_COUNT,1) = '$' THEN
			WS_TIPO := SUBSTR(WS_TEXTO,WS_COUNT,1);
			WS_VAR  := '';
			WS_COUNT := WS_COUNT + 1;
			IF  SUBSTR(WS_TEXTO,WS_COUNT,1)<>'[' THEN
				RETURN('ERRO');
			ELSE
				LOOP
				   WS_COUNT  := WS_COUNT + 1;
				   IF  SUBSTR(WS_TEXTO,WS_COUNT,1)=']' THEN
					   BEGIN
							IF INSTR(WS_VAR, '%') > 0 THEN
                              WS_FUNCAO := WS_FUNCAO||'(case when '||PRM_CD_COLUNA||' like '||CHR(39)||WS_VAR||CHR(39)||' then '||PRM_VL_AGRUPADOR||' else 0 end)';
                            ELSE
                              WS_FUNCAO := WS_FUNCAO||'(case when '||PRM_CD_COLUNA||' = '||CHR(39)||WS_VAR||CHR(39)||' then '||PRM_VL_AGRUPADOR||' else 0 end)';
                            END IF;
                       EXCEPTION WHEN OTHERS THEN
					   		WS_FUNCAO := WS_FUNCAO||'(case when '||PRM_CD_COLUNA||' = '||CHR(39)||WS_VAR||CHR(39)||' then '||PRM_VL_AGRUPADOR||' else 0 end)';
					   END;
					   EXIT;
				   END IF;
				   WS_VAR := WS_VAR||SUBSTR(WS_TEXTO,WS_COUNT,1);
				END LOOP;
			END IF;
		END IF;

	END LOOP;

    RETURN(WS_FUNCAO);

END GL_CALCULADA;

FUNCTION LIST_POST ( PRM_OBJETO     VARCHAR2 DEFAULT NULL,
                     PRM_PARAMETROS VARCHAR2 DEFAULT NULL,
					 PRM_GROUP      VARCHAR2 DEFAULT NULL ) RETURN TAB_MENSAGENS PIPELINED AS

	CURSOR CRS_MENSAGENS IS
         SELECT DT_POST, CD_USUARIO, CD_GROUP, TYPE_TEXT, SELECT_LINE, POST_ID
         FROM  TEXT_POST POST
         WHERE (OBJECT_ID=PRM_OBJETO) AND
                (TRUNC(TO_DATE(SYSDATE, 'DD-MM-YY'))-TRUNC(TO_DATE(DT_POST, 'DD-MM-YY')) <= TIME_LIVE OR TIME_LIVE = '0') AND
                ((USER IN (SELECT CD_USUARIO FROM GUSERS_ITENS GIT WHERE GIT.CD_GROUP=POST.CD_GROUP) OR USER=CD_GROUP) OR (USER=CD_USUARIO) OR (CD_GROUP='todos'))
				AND (CD_GROUP = NVL(PRM_GROUP, CD_GROUP) OR CD_USUARIO = NVL(PRM_GROUP, CD_USUARIO))
				ORDER BY DT_POST;

    WS_MENSAGENS   CRS_MENSAGENS%ROWTYPE;

   	WS_COUNT            NUMBER := 1;

BEGIN

        OPEN CRS_MENSAGENS;
	      LOOP
		        FETCH CRS_MENSAGENS INTO WS_MENSAGENS;
		              EXIT WHEN CRS_MENSAGENS%NOTFOUND;

                          SELECT COUNT(*) INTO WS_COUNT FROM 
                          (
                            SELECT CD_COLUNA, MAX(CT_PARAMETRO) CT_PARAMETRO, MAX(CT_MSG) CT_MSG FROM (
                                   SELECT DISTINCT CD_COLUNA, ' ' CT_PARAMETRO, CD_CONTEUDO CT_MSG FROM TABLE(FUN.VPIPE_PAR(WS_MENSAGENS.SELECT_LINE)) 
                                   UNION ALL
                                   SELECT DISTINCT CD_COLUNA, CD_CONTEUDO, ' ' FROM TABLE(FUN.VPIPE_PAR(PRM_PARAMETROS))
                          ) GROUP BY CD_COLUNA) WHERE CT_PARAMETRO <> CT_MSG;

                          IF  WS_COUNT = 0 THEN
                              PIPE ROW (GER_MENSAGENS (WS_MENSAGENS.DT_POST, WS_MENSAGENS.CD_USUARIO, WS_MENSAGENS.CD_GROUP, WS_MENSAGENS.TYPE_TEXT, WS_MENSAGENS.POST_ID));
                          END IF;
		    END LOOP;
        CLOSE CRS_MENSAGENS;

END LIST_POST;

FUNCTION LIST_ALL_POST ( PRM_PARAMETROS VARCHAR2 DEFAULT NULL,
                         PRM_GROUP      VARCHAR2 DEFAULT NULL ) RETURN TAB_MENSAGENS PIPELINED AS

	CURSOR CRS_MENSAGENS(PRM_USUARIO VARCHAR2) IS
         SELECT DT_POST, CD_USUARIO, CD_GROUP, TYPE_TEXT, SELECT_LINE, POST_ID
         FROM  TEXT_POST POST
         WHERE (TRUNC(TO_DATE(SYSDATE, 'DD-MM-YY'))-TRUNC(TO_DATE(DT_POST, 'DD-MM-YY')) <= TIME_LIVE OR TIME_LIVE = '0') AND
                ((PRM_USUARIO IN (SELECT CD_USUARIO FROM GUSERS_ITENS GIT WHERE GIT.CD_GROUP=POST.CD_GROUP) OR PRM_USUARIO = CD_GROUP) OR (PRM_USUARIO = CD_USUARIO) OR (CD_GROUP='todos'))
				AND (CD_GROUP = NVL(PRM_GROUP, CD_GROUP) OR CD_USUARIO = NVL(PRM_GROUP, CD_USUARIO))
				ORDER BY DT_POST;

    WS_MENSAGENS   CRS_MENSAGENS%ROWTYPE;

   	WS_COUNT            NUMBER := 1;

BEGIN

        OPEN CRS_MENSAGENS(GBL.GETUSUARIO);
	      LOOP
		        FETCH CRS_MENSAGENS INTO WS_MENSAGENS;
		              EXIT WHEN CRS_MENSAGENS%NOTFOUND;

                          SELECT COUNT(*) INTO WS_COUNT FROM 
                          (
                            SELECT CD_COLUNA, MAX(CT_PARAMETRO) CT_PARAMETRO, MAX(CT_MSG) CT_MSG FROM (
                                   SELECT DISTINCT CD_COLUNA, ' ' CT_PARAMETRO, CD_CONTEUDO CT_MSG FROM TABLE(FUN.VPIPE_PAR(WS_MENSAGENS.SELECT_LINE)) 
                                   UNION ALL
                                   SELECT DISTINCT CD_COLUNA, CD_CONTEUDO, ' ' FROM TABLE(FUN.VPIPE_PAR(PRM_PARAMETROS))
                          ) GROUP BY CD_COLUNA) WHERE CT_PARAMETRO <> CT_MSG;

                          IF  WS_COUNT = 0 THEN
                              PIPE ROW (GER_MENSAGENS (WS_MENSAGENS.DT_POST, WS_MENSAGENS.CD_USUARIO, WS_MENSAGENS.CD_GROUP, WS_MENSAGENS.TYPE_TEXT, WS_MENSAGENS.POST_ID));
                          END IF;
		    END LOOP;
        CLOSE CRS_MENSAGENS;

END LIST_ALL_POST;

FUNCTION VERIFICA_POST ( PRM_OBJETO     VARCHAR2 DEFAULT NULL,
                         PRM_PARAMETROS VARCHAR2 DEFAULT NULL ) RETURN BOOLEAN AS

 CURSOR CRS_MENSAGENS IS
         SELECT DT_POST, CD_USUARIO, TYPE_TEXT, SELECT_LINE, CD_GROUP
         FROM  TEXT_POST POST
         WHERE  OBJECT_ID=PRM_OBJETO AND
                TRUNC(TO_DATE(SYSDATE, 'DD-MM-YY'))-TRUNC(TO_DATE(DT_POST, 'DD-MM-YY')) <= TIME_LIVE AND
                ((USER IN (SELECT CD_USUARIO FROM GUSERS_ITENS GIT WHERE GIT.CD_GROUP=POST.CD_GROUP)) OR (POST.CD_GROUP=USER)  OR (USER=CD_USUARIO) OR (CD_GROUP='todos'));

    WS_MENSAGENS   CRS_MENSAGENS%ROWTYPE;

    WS_COUNT            NUMBER := 1;

BEGIN
        OPEN CRS_MENSAGENS;
       LOOP
          FETCH CRS_MENSAGENS INTO WS_MENSAGENS;
                EXIT WHEN CRS_MENSAGENS%NOTFOUND;

                          SELECT COUNT(*) INTO WS_COUNT FROM 
                          (
                            SELECT CD_COLUNA, MAX(CT_PARAMETRO) CT_PARAMETRO, MAX(CT_MSG) CT_MSG FROM (
                                   SELECT DISTINCT CD_COLUNA, ' ' CT_PARAMETRO, CD_CONTEUDO CT_MSG FROM TABLE(FUN.VPIPE_PAR(WS_MENSAGENS.SELECT_LINE)) 
                                   UNION ALL
                                   SELECT DISTINCT CD_COLUNA, CD_CONTEUDO, ' ' FROM TABLE(FUN.VPIPE_PAR(PRM_PARAMETROS))
                          ) GROUP BY CD_COLUNA) WHERE CT_PARAMETRO <> CT_MSG;

                  EXIT WHEN WS_COUNT = 0;

      END LOOP;
        CLOSE CRS_MENSAGENS;

        IF  WS_COUNT > 0 THEN
            RETURN(FALSE);
        ELSE
            RETURN(TRUE);
        END IF;

END VERIFICA_POST;

FUNCTION EXT_MASC ( PRM_VALUE VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

    WS_VALUE VARCHAR2(30);

BEGIN

    CASE PRM_VALUE
    WHEN ',' THEN
        WS_VALUE := FUN.LANG('virgula');
    WHEN '.' THEN
	    WS_VALUE := FUN.LANG('ponto');
	WHEN '-' THEN
	    WS_VALUE := FUN.LANG('hífen');
	WHEN ':' THEN
	    WS_VALUE := FUN.LANG('dois pontos');
	ELSE
	    WS_VALUE := '';
	END CASE;
	
	RETURN (WS_VALUE);

END EXT_MASC;

FUNCTION INIT_TEXT_POST RETURN NUMBER IS

    WS_COUNT          NUMBER;

BEGIN
        
    SELECT COUNT(*) INTO WS_COUNT FROM TEXT_POST
    WHERE (CD_GROUP = USER OR CD_GROUP = 'todos' OR CD_GROUP IN (SELECT CD_GROUP FROM GUSERS_ITENS T1 WHERE T1.CD_USUARIO = USER)) AND
	CD_USUARIO <> USER AND
	CD_USUARIO <> 'SYS' AND
    POST_ID NOT IN (SELECT ID_POST FROM CHECK_POST WHERE CD_USUARIO = USER) AND
	TRUNC(TO_DATE(SYSDATE, 'DD-MM-YY'))-TRUNC(TO_DATE(DT_POST, 'DD-MM-YY')) <= TIME_LIVE AND
	NVL(TRIM(SELECT_LINE), '999999999') = '999999999';
    
	RETURN(WS_COUNT);
EXCEPTION WHEN OTHERS THEN
    RETURN(0);
END INIT_TEXT_POST;

FUNCTION CHECK_PERMISSAO ( PRM_OBJETO VARCHAR2 DEFAULT NULL, PRM_USUARIO VARCHAR2 DEFAULT NULL) RETURN CHAR AS

 WS_RESTRITO    NUMBER;
 WS_EXCLUSIVO   NUMBER;
 WS_LIBERADO    NUMBER;
 WS_SAIDA       CHAR(1) := 'N';

BEGIN

  BEGIN
   SELECT COUNT(*) INTO WS_EXCLUSIVO
   FROM OBJECT_RESTRICTION
   WHERE USUARIO      = 'DWU' AND
         CD_OBJETO    = PRM_OBJETO AND
         ST_RESTRICAO = 'X';

   SELECT COUNT(*) INTO WS_LIBERADO
   FROM OBJECT_RESTRICTION
   WHERE USUARIO      = NVL(PRM_USUARIO,GBL.GETUSUARIO) AND
         CD_OBJETO    = PRM_OBJETO AND
         ST_RESTRICAO = 'L';

   SELECT COUNT(*) INTO WS_RESTRITO
   FROM OBJECT_RESTRICTION
   WHERE USUARIO      = NVL(PRM_USUARIO, GBL.GETUSUARIO) AND
         CD_OBJETO    = PRM_OBJETO AND
         ST_RESTRICAO = 'I';

   IF  WS_EXCLUSIVO<>0 THEN
       IF  WS_LIBERADO=0 THEN
           WS_SAIDA := 'N';
       ELSE
           WS_SAIDA := 'S';
       END IF;
   ELSE
       IF  WS_RESTRITO <> 0 THEN
           WS_SAIDA := 'N';
       ELSE
           WS_SAIDA := 'S';
       END IF;
   END IF;

   EXCEPTION
      WHEN OTHERS THEN
           WS_SAIDA := 'N';
  END;

  RETURN(WS_SAIDA);

END CHECK_PERMISSAO;

FUNCTION C2B ( P_CLOB IN CLOB ) RETURN BLOB IS

  TEMP_BLOB   BLOB;
  DEST_OFFSET NUMBER  := 1;
  SRC_OFFSET  NUMBER  := 1;
  AMOUNT      INTEGER := DBMS_LOB.LOBMAXSIZE;
  BLOB_CSID   NUMBER  := DBMS_LOB.DEFAULT_CSID;
  LANG_CTX    INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
  WARNING     INTEGER;
BEGIN
 DBMS_LOB.CREATETEMPORARY(LOB_LOC=>TEMP_BLOB, CACHE=>TRUE);

  DBMS_LOB.CONVERTTOBLOB(TEMP_BLOB, P_CLOB,AMOUNT,DEST_OFFSET,SRC_OFFSET,BLOB_CSID,LANG_CTX,WARNING);
  RETURN TEMP_BLOB;
END C2B;


FUNCTION NSLOOKUP ( PRM_ENDERECO VARCHAR DEFAULT NULL ) RETURN VARCHAR2 AS

   WS_NOME      VARCHAR2(2000);
   WS_ERRO      EXCEPTION;

BEGIN

  BEGIN
      WS_NOME := UTL_INADDR.GET_HOST_NAME(TRIM(PRM_ENDERECO));
  EXCEPTION
      WHEN OTHERS THEN
           WS_NOME := 'NO_NAME';
  END;

   RETURN (WS_NOME);

EXCEPTION
   WHEN OTHERS THEN
      RETURN ('ERRO');

END NSLOOKUP;

FUNCTION LANG ( PRM_TEXTO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

    WS_TRADUZIDO   VARCHAR2(4000);
    WS_PADRAO      VARCHAR2(40);
BEGIN
    
    IF NVL(FUN.RET_VAR('LANG'), 'N') = 'S' THEN
    
        








        

        WS_PADRAO := GBL.GETLANG;

        WS_TRADUZIDO := PRM_TEXTO;
        
        BEGIN

            IF WS_PADRAO = 'ENGLISH' THEN
                SELECT MAX(TRADUZIDO_INGLES) INTO WS_TRADUZIDO
                FROM UTL_TRADUCOES_FEITAS WHERE TEXTO=PRM_TEXTO;
            END IF;

            IF WS_PADRAO = 'SPANISH' THEN
                SELECT MAX(TRADUZIDO_ESPANHOL) INTO WS_TRADUZIDO
                FROM UTL_TRADUCOES_FEITAS WHERE TEXTO=PRM_TEXTO;
            END IF;

            IF WS_PADRAO = 'ITALIAN' THEN
                SELECT MAX(TRADUZIDO_ITALIANO) INTO WS_TRADUZIDO
                FROM UTL_TRADUCOES_FEITAS WHERE TEXTO=PRM_TEXTO;
            END IF;

            IF WS_PADRAO = 'GERMAN' THEN
                SELECT MAX(TRADUZIDO_ALEMAO) INTO WS_TRADUZIDO
                FROM UTL_TRADUCOES_FEITAS WHERE TEXTO=PRM_TEXTO;
            END IF;

        EXCEPTION
            WHEN OTHERS THEN 
            WS_TRADUZIDO := '*'||PRM_TEXTO;
        END;

        RETURN (NVL(WS_TRADUZIDO, '*'||PRM_TEXTO));
    ELSE
        RETURN PRM_TEXTO;
    END IF;

END LANG;

FUNCTION GET_TRANSLATOR ( PRM_TEXTO        VARCHAR2,
                          PRM_ORIGEM_LANG  VARCHAR2,
                          PRM_DESTINO_LANG VARCHAR2 ) RETURN VARCHAR2 AS 

     WS_REQUEST VARCHAR2(4000);

BEGIN

    WS_REQUEST := UTL_HTTP.REQUEST('http://translate.google.com/translate_a/t?client=j'||CHR(38)||'text='||TRIM(REPLACE(PRM_TEXTO, ' ', '+'))||CHR(38)||'hl=pt'||CHR(38)||'sl='||PRM_ORIGEM_LANG||CHR(38)||'tl='||PRM_DESTINO_LANG);
    WS_REQUEST := REGEXP_SUBSTR(WS_REQUEST,'trans\":(\".*?\"),\"');
    WS_REQUEST := SUBSTR(WS_REQUEST,9,LENGTH(WS_REQUEST)-11);

    RETURN(WS_REQUEST);

END GET_TRANSLATOR;

FUNCTION RET_PAR ( PRM_SESSAO VARCHAR2 ) RETURN VARCHAR2 AS

    WS_PADRAO VARCHAR2(80);

BEGIN

    BEGIN
        SELECT CONTEUDO INTO WS_PADRAO
        FROM   PARAMETRO_USUARIO
        WHERE  CD_USUARIO = (SELECT CONTEUDO FROM VAR_CONTEUDO WHERE USUARIO = PRM_SESSAO AND VARIAVEL = 'USUARIO') AND
               CD_PADRAO='CD_LINGUAGEM';
    EXCEPTION
        WHEN OTHERS THEN
            WS_PADRAO := 'PORTUGUESE';
    END;

    RETURN WS_PADRAO;

END;

FUNCTION UTRANSLATE ( PRM_CD_COLUNA VARCHAR2,
                      PRM_TABELA    VARCHAR2,
                      PRM_DEFAULT   VARCHAR2,
                      PRM_PADRAO    VARCHAR2 DEFAULT 'PORTUGUESE') RETURN VARCHAR2 AS

    WS_PADRAO      VARCHAR2(40);
    WS_TEXTO       VARCHAR2(4000);

BEGIN

    IF NVL(FUN.RET_VAR('LANG'), 'N') = 'S' THEN

        BEGIN
            SELECT TEXTO INTO WS_TEXTO
            FROM   TRADUCAO_COLUNAS
            WHERE  CD_TABELA    = UPPER(PRM_TABELA) AND
                CD_COLUNA    = UPPER(PRM_CD_COLUNA) AND
                CD_LINGUAGEM = PRM_PADRAO AND 
                LANG_DEFAULT = PRM_DEFAULT;
                
        EXCEPTION
            WHEN OTHERS THEN
                WS_TEXTO := PRM_DEFAULT;
        END;

        RETURN (TRIM(WS_TEXTO));

    ELSE

        RETURN PRM_DEFAULT;

    END IF;

END UTRANSLATE;

FUNCTION LIST_VIEW ( PRM_TIPO CHAR DEFAULT NULL) RETURN VARCHAR2 AS

    WS_GRUPO VARCHAR2(40) := '999999999';
	WS_RESULTADO LONG;

BEGIN

    WS_RESULTADO := '<option selected disabled hidden value="">'||FUN.LANG('SELECIONE UMA VIEW')||'</option>';
	
	IF PRM_TIPO = 'T' THEN
	    WS_RESULTADO := WS_RESULTADO||'<option value="">'||FUN.LANG('TODAS')||'</option>';
	END IF;
	
    FOR I IN (SELECT NM_MICRO_VISAO, DS_MICRO_VISAO, CD_GRUPO_FUNCAO FROM MICRO_VISAO ORDER BY CD_GRUPO_FUNCAO, NM_MICRO_VISAO) LOOP
	    IF(WS_GRUPO <> I.CD_GRUPO_FUNCAO) THEN
	        WS_RESULTADO := WS_RESULTADO||'<optgroup label="'||FUN.UTRANSLATE('CD_GRUPO', 'GRUPOS_FUNCAO', I.CD_GRUPO_FUNCAO)||'"></optgroup>';
		    WS_GRUPO := I.CD_GRUPO_FUNCAO;
	    END IF;
	    WS_RESULTADO := WS_RESULTADO||'<option value="'||I.NM_MICRO_VISAO||'">['||FUN.UTRANSLATE('NM_MICRO_VISAO', 'MICRO_VISAO', I.NM_MICRO_VISAO)||'] '||FUN.UTRANSLATE('DS_MICRO_VISAO', 'MICRO_VISAO', I.DS_MICRO_VISAO)||' </option>';
	END LOOP;
  
    RETURN WS_RESULTADO;

EXCEPTION WHEN OTHERS THEN
    RETURN '';
END LIST_VIEW;

PROCEDURE REQUEST_PROGS AS

   CURSOR CRS_SEQ (PRM_DADOS VARCHAR2 ) IS
           SELECT COLUMN_VALUE
           FROM   TABLE(FUN.VPIPE(PRM_DADOS));

   WS_SEQ  			CRS_SEQ%ROWTYPE;

   CURSOR CRS_UPSEQ (PRM_NOVA_VERSAO NUMBER) IS
           SELECT   SEQUENCIA,
                    VERSAO_SISTEMA,
                    NM_CONTEUDO,
                    TIPO,
                    NAME,
                    MIME_TYPE,
                    DOC_SIZE,
                    DAD_CHARSET,
                    LAST_UPDATED,
                    CONTENT_TYPE
           FROM     UPDATE_SEQUENCE
           WHERE    VERSAO_SISTEMA=PRM_NOVA_VERSAO
           ORDER BY SEQUENCIA;

   WS_UPSEQ  			CRS_UPSEQ%ROWTYPE;

   WS_PIECES        UTL_HTTP.HTML_PIECES;

   WS_DADOS         VARCHAR2(4000);
   WS_VARIAVEL      VARCHAR2(8000);
   WS_TEMP          CLOB;
   WS_TEMP_LONG     LONG;
   WS_NOVA_VERSAO   NUMBER       := NULL;
   WS_CTCOL         NUMBER;
   WS_LOB_LEN       NUMBER;
   V_INTCUR         PLS_INTEGER;
   V_INTIDX         PLS_INTEGER;
   V_INTNUMROWS     PLS_INTEGER;
   V_VCSTMT         DBMS_SQL.VARCHAR2A;
   WS_ITENS         DBMS_SQL.VARCHAR2A;
   LEN              PLS_INTEGER;
   PRM_TIPO         VARCHAR2(30) := 'JAVA_SCRIPT';
   PRM_CONTEUDO     VARCHAR2(80) := 'TESTE_JAVA';
   PRM_VERSAO       NUMBER       := 0;
   WS_URL           VARCHAR2(4000);
   WS_COUNT         NUMBER;

BEGIN

















    EXECUTE IMMEDIATE ('truncate table UPDATE_SEQUENCE');

    WS_CTCOL := 0;

    WS_URL   :=  'http://'||FUN.RET_VAR('DOMINIO_REG')||':7777/update/dwu.GET_PROGS?Prm_Senha=XXXX&Prm_Conteudo=LIST_SCRIPTS&prm_versao='||PRM_VERSAO||'&prm_tipo=GET_LIST';
    WS_DADOS :=  UTL_HTTP.REQUEST(WS_URL);

    OPEN CRS_SEQ(WS_DADOS);
        LOOP
            FETCH CRS_SEQ INTO WS_SEQ;
            EXIT WHEN CRS_SEQ%NOTFOUND;

            WS_CTCOL := WS_CTCOL + 1;
            WS_ITENS(WS_CTCOL) := TRIM(WS_SEQ.COLUMN_VALUE);
            IF  WS_CTCOL = 10 THEN
                WS_CTCOL := 0;
                INSERT INTO UPDATE_SEQUENCE VALUES (TRIM(WS_ITENS(1)),TRIM(WS_ITENS(2)),TRIM(WS_ITENS(3)),TRIM(WS_ITENS(4)),TRIM(WS_ITENS(5)),TRIM(WS_ITENS(6)),TRIM(WS_ITENS(7)),TRIM(WS_ITENS(8)),TO_DATE(NVL(TRIM(WS_ITENS(9)),'010199'),'ddmmyy'),TRIM(WS_ITENS(10)));
                IF  WS_NOVA_VERSAO IS NULL THEN
                    WS_NOVA_VERSAO := WS_ITENS(2);
                END IF;
                COMMIT;
            END IF;

        END LOOP;   
    CLOSE CRS_SEQ;

    OPEN CRS_UPSEQ(WS_NOVA_VERSAO);
    LOOP
    FETCH CRS_UPSEQ INTO WS_UPSEQ;
          EXIT WHEN CRS_UPSEQ%NOTFOUND;

          WS_URL    := 'http://'||FUN.RET_VAR('DOMINIO_REG')||':7777/update/dwu.get_progs?Prm_Senha=XXXX&Prm_Conteudo='||TRIM(WS_UPSEQ.NM_CONTEUDO)||'&prm_versao='||TRIM(WS_UPSEQ.VERSAO_SISTEMA)||'&prm_tipo='||TRIM(WS_UPSEQ.TIPO);
          WS_PIECES :=  UTL_HTTP.REQUEST_PIECES(WS_URL,65535);

          IF  WS_UPSEQ.TIPO IN ('PROCEDURE','PACKAGE_SPEC','PACKAGE_BODY','FUNCTION') THEN
              LEN := 1;
              V_VCSTMT(LEN) := '';

              FOR I IN 1..WS_PIECES.COUNT LOOP

                      IF  INSTR(WS_PIECES(I),CHR(10)) = 0 THEN
                           V_VCSTMT(LEN) := V_VCSTMT(LEN)||SUBSTR(WS_PIECES(I),1,LENGTH(WS_PIECES(I)));
                      ELSE
                           V_VCSTMT(LEN) := V_VCSTMT(LEN)||SUBSTR(WS_PIECES(I),1,INSTR(WS_PIECES(I),CHR(10)));
                           LEN := LEN + 1;
                           V_VCSTMT(LEN) := '';
                           V_VCSTMT(LEN) := V_VCSTMT(LEN)||SUBSTR(WS_PIECES(I),(INSTR(WS_PIECES(I),CHR(10))+1),LENGTH(WS_PIECES(I)));
                      END IF;

              END LOOP;

              V_INTIDX := LEN;
              V_INTCUR := DBMS_SQL.OPEN_CURSOR;
              DBMS_SQL.PARSE( C => V_INTCUR, STATEMENT => V_VCSTMT, LB => 1, UB => V_INTIDX, LFFLG => FALSE, LANGUAGE_FLAG => DBMS_SQL.NATIVE);
              V_INTNUMROWS := DBMS_SQL.EXECUTE(V_INTCUR);
              DBMS_SQL.CLOSE_CURSOR(V_INTCUR);

          END IF;


          IF  WS_UPSEQ.TIPO = 'DOCUMENTO' THEN
              WS_TEMP := '';
              LEN := 0;
              FOR I IN 1..WS_PIECES.COUNT LOOP
                  WS_TEMP := WS_TEMP||WS_PIECES(I);
              END LOOP;
              DELETE FROM TAB_DOCUMENTOS WHERE NAME=WS_UPSEQ.NAME;
              COMMIT;
              INSERT INTO TAB_DOCUMENTOS VALUES (WS_UPSEQ.NAME,WS_UPSEQ.MIME_TYPE,WS_UPSEQ.DOC_SIZE,WS_UPSEQ.DAD_CHARSET,WS_UPSEQ.LAST_UPDATED,WS_UPSEQ.CONTENT_TYPE,FUN.C2B(WS_TEMP), GBL.GETUSUARIO);
              COMMIT;
          END IF;

          IF  WS_UPSEQ.TIPO = 'SCRIPT' THEN
              WS_TEMP_LONG := '';
              LEN := 0;
              FOR I IN 1..WS_PIECES.COUNT LOOP
                  WS_TEMP_LONG := WS_TEMP_LONG||WS_PIECES(I);
              END LOOP;
              EXECUTE IMMEDIATE WS_TEMP_LONG;
              COMMIT;
          END IF;

    END LOOP;
    CLOSE CRS_UPSEQ;

END REQUEST_PROGS;

FUNCTION CONVERT_CALENDAR ( PRM_VALOR VARCHAR2 DEFAULT NULL,
                            PRM_TIPO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS
			
BEGIN
    IF PRM_VALOR <> 'todos' THEN
		IF PRM_TIPO = 'mes' THEN
			CASE TO_NUMBER(PRM_VALOR)
				WHEN '1' THEN
					RETURN FUN.LANG('janeiro');
				WHEN '2' THEN
					RETURN FUN.LANG('fevereiro');
				WHEN '3' THEN
					RETURN FUN.LANG('mar&ccedil;o');
				WHEN '4' THEN
					RETURN FUN.LANG('abril');
				WHEN '5' THEN
					RETURN FUN.LANG('maio');
				WHEN '6' THEN
					RETURN FUN.LANG('junho');
				WHEN '7' THEN
					RETURN FUN.LANG('julho');
				WHEN '8' THEN
					RETURN FUN.LANG('agosto');
				WHEN '9' THEN
					RETURN FUN.LANG('setembro');
				WHEN '10' THEN
					RETURN FUN.LANG('outubro');
				WHEN '11' THEN
					RETURN FUN.LANG('novembro');
				ELSE
					RETURN FUN.LANG('dezembro');
			END CASE;
		ELSE
			CASE TO_NUMBER(PRM_VALOR)
				WHEN '1' THEN
					RETURN FUN.LANG('domingo');
				WHEN '2' THEN
					RETURN FUN.LANG('segunda-feira');
				WHEN '3' THEN
					RETURN FUN.LANG('ter&ccedil;a-feira');
				WHEN '4' THEN
					RETURN FUN.LANG('quarta-feira');
				WHEN '5' THEN
					RETURN FUN.LANG('quinta-feira');
				WHEN '6' THEN
					RETURN FUN.LANG('sexta');
				ELSE
					RETURN FUN.LANG('sabado');
			END CASE;
	    END IF;
	ELSE
	    RETURN 'todos';
	END IF;

END CONVERT_CALENDAR;

FUNCTION XFORMULA ( PRM_TEXTO  VARCHAR2 DEFAULT NULL, 
                    PRM_SCREEN VARCHAR2 DEFAULT NULL,
                    PRM_SPACE  VARCHAR2 DEFAULT 'N' ) RETURN VARCHAR2 AS

    WS_TEXTO          VARCHAR2(3000);
    WS_FUNCAO         VARCHAR2(3000);
    WS_VAR            VARCHAR2(1000);
    WS_AGRUPADOR      VARCHAR2(20);
    WS_TIPO           VARCHAR2(1);
    WS_CALCULADA      VARCHAR2(1);
    WS_FORMULA        VARCHAR2(4000);

    WS_COUNT          NUMBER;

BEGIN

    WS_COUNT := 0;
    WS_TEXTO := UPPER(PRM_TEXTO)||'#';
    WS_FUNCAO := '';

LOOP
    WS_COUNT := WS_COUNT + 1;
    IF  SUBSTR(WS_TEXTO,WS_COUNT,1)='#' THEN
        EXIT;
    END IF;

    IF  SUBSTR(PTG_TRANS(WS_TEXTO),WS_COUNT,1) IN (',','_','Q','W','E','R','T','Y','U','I','O','P','A','S','D','F','G','H','J','K','L','Z','X','C','V','B','N','M') THEN
        WS_FUNCAO := WS_FUNCAO||SUBSTR(WS_TEXTO,WS_COUNT,1);
    END IF;

    IF  PRM_SPACE = 'S' THEN
        IF  SUBSTR(WS_TEXTO,WS_COUNT,1) = ' ' THEN
            WS_FUNCAO := WS_FUNCAO||SUBSTR(WS_TEXTO,WS_COUNT,1);
        END IF;
    END IF;

    IF  SUBSTR(WS_TEXTO,WS_COUNT,1) IN ('|','+','-','/','*','(',')','>', '<', CHR(39), '=', ':') THEN
        WS_FUNCAO := WS_FUNCAO||SUBSTR(WS_TEXTO,WS_COUNT,1);
    END IF;

    IF  SUBSTR(WS_TEXTO,WS_COUNT,1) IN ('.','0','1','2','3','4','5','6','7','8','9') THEN
        WS_FUNCAO := WS_FUNCAO||SUBSTR(WS_TEXTO,WS_COUNT,1);
    END IF;

    IF  SUBSTR(WS_TEXTO,WS_COUNT,1) IN ('$','@','&') THEN
        WS_TIPO := SUBSTR(WS_TEXTO,WS_COUNT,1);
        WS_VAR  := '';
        WS_COUNT := WS_COUNT + 1;
        IF  SUBSTR(WS_TEXTO,WS_COUNT,1)<>'[' THEN
            RETURN('ERRO');
        ELSE
            LOOP
               WS_COUNT  := WS_COUNT + 1;
               IF  SUBSTR(WS_TEXTO,WS_COUNT,1)=']' THEN
                   IF  WS_TIPO = '$' THEN
                       WS_FUNCAO := WS_FUNCAO||CHR(39)||FUN.GPARAMETRO('$['||WS_VAR||']', PRM_SCREEN => PRM_SCREEN)||CHR(39);
                   ELSE
                       IF  WS_TIPO = '&' THEN
                           WS_FUNCAO := WS_FUNCAO||CHR(39)||FUN.GPARAMETRO('$['||WS_VAR||']', PRM_SCREEN => PRM_SCREEN)||CHR(39);
                       ELSE
                           WS_FUNCAO := WS_FUNCAO||FUN.GVALOR(WS_VAR);
                       END IF;
                  END IF;
                  EXIT;
               END IF;
               WS_VAR := WS_VAR||SUBSTR(WS_TEXTO,WS_COUNT,1);
             END LOOP;
        END IF;
    END IF;

END LOOP;

RETURN(WS_FUNCAO);

END XFORMULA;

FUNCTION URLENCODE ( P_STR IN VARCHAR2 ) RETURN VARCHAR2 AS   
       
    L_TMP   VARCHAR2(6000);  
    L_BAD   VARCHAR2(100) DEFAULT ' >%}\~];?@&<#{|^[`/:=$+''"';  
    L_CHAR  CHAR(1);  
BEGIN  
    FOR I IN 1 .. NVL(LENGTH(P_STR),0) LOOP  
        L_CHAR :=  SUBSTR(P_STR,I,1);  
        IF ( INSTR( L_BAD, L_CHAR ) > 0 )  
        THEN  
            L_TMP := L_TMP || '%' ||  
                            TO_CHAR( ASCII(L_CHAR), 'fmXX' );  
        ELSE  
            L_TMP := L_TMP || L_CHAR;  
        END IF;  
    END LOOP;  
    
    RETURN L_TMP;  
END URLENCODE;


FUNCTION CHECK_ROTULOC ( PRM_COLUNA VARCHAR2 DEFAULT NULL,
                         PRM_VISAO VARCHAR2 DEFAULT NULL,
						 PRM_SCREEN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS
										 
	WS_TEM VARCHAR2(4000);
	WS_TOT VARCHAR2(4000);
    WS_PADRAO VARCHAR2(80);
										 
BEGIN

    FOR I IN(SELECT COLUMN_VALUE FROM TABLE((FUN.VPIPE(PRM_COLUNA)))) LOOP

	    SELECT NVL(TRIM(ROTULO_C), 'N/A') INTO WS_TEM FROM MICRO_COLUNA WHERE CD_COLUNA = REPLACE(I.COLUMN_VALUE, '|', '') AND CD_MICRO_VISAO = PRM_VISAO;
		
		IF WS_TEM = 'N/A' THEN
		    WS_PADRAO := GBL.GETLANG;
            SELECT FUN.UTRANSLATE('NM_ROTULO', PRM_VISAO, NM_ROTULO, WS_PADRAO) INTO WS_TEM FROM MICRO_COLUNA WHERE CD_COLUNA = REPLACE(I.COLUMN_VALUE, '|', '') AND CD_MICRO_VISAO = PRM_VISAO;
		ELSE
            WS_TEM := REPLACE(WS_TEM, CHR(10), '<BR>');
		    WS_TEM := FUN.XEXEC('EXEC='||REPLACE(WS_TEM, '$[CONCAT]','||'), PRM_SCREEN);
			IF NVL(TRIM(WS_TEM), 'N/A') = 'N/A' THEN
			    SELECT NM_ROTULO INTO WS_TEM FROM MICRO_COLUNA WHERE CD_COLUNA = REPLACE(I.COLUMN_VALUE, '|', '') AND CD_MICRO_VISAO = PRM_VISAO;
			END IF;
		END IF;

        WS_TEM := REPLACE(WS_TEM, '<BR>', CHR(10));
		
		WS_TOT := WS_TEM||'|'||WS_TOT;
		
    END LOOP;
    
    IF LENGTH(WS_TOT) > 0 THEN
        WS_TOT := SUBSTR(WS_TOT, 0, LENGTH(WS_TOT)-1);
    END IF;
	
    RETURN TRIM(WS_TOT);
EXCEPTION WHEN OTHERS THEN
    RETURN TRIM(PRM_COLUNA);
END CHECK_ROTULOC;


FUNCTION CONV_TEMPLATE ( PRM_MICRO_VISAO VARCHAR2 DEFAULT NULL,
                         PRM_AGRUPADORES VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 IS
	     
		 
    WS_AGRUPADOR VARCHAR2(10);
    WS_FORMULA VARCHAR2(3000);
	WS_COUNT NUMBER;
    BEGIN

    SELECT COUNT(*) INTO WS_COUNT FROM (SELECT NVL(COLUMN_VALUE, 'N/A') AS VALOR FROM TABLE(FUN.VPIPE((SELECT NVL(PROPRIEDADE, 'N/A') FROM OBJECT_ATTRIB WHERE CD_PROP = 'TPT' AND OWNER = GBL.GETUSUARIO AND CD_OBJECT = PRM_AGRUPADORES AND ROWNUM = 1 AND SCREEN = PRM_MICRO_VISAO)))) WHERE VALOR <> 'N/A';
   
    SELECT ST_AGRUPADOR, FORMULA 
		INTO WS_AGRUPADOR, WS_FORMULA 
		FROM MICRO_COLUNA 
		WHERE CD_COLUNA = (SELECT COLUMN_VALUE FROM TABLE(FUN.VPIPE((PRM_AGRUPADORES))) WHERE ROWNUM = 1) AND CD_MICRO_VISAO = PRM_MICRO_VISAO;

	IF WS_COUNT <> 0 THEN
		 SELECT PROPRIEDADE INTO WS_FORMULA FROM OBJECT_ATTRIB WHERE CD_PROP = 'TPT' AND OWNER = GBL.GETUSUARIO AND CD_OBJECT = PRM_AGRUPADORES AND ROWNUM = 1 AND SCREEN = PRM_MICRO_VISAO;
		 WS_FORMULA := SUBSTR(WS_FORMULA,2,LENGTH(WS_FORMULA));
	END IF;
	
    IF WS_AGRUPADOR <> 'TPT' THEN
	    WS_FORMULA := PRM_AGRUPADORES;
	END IF;
	
	
	RETURN(WS_FORMULA);
END CONV_TEMPLATE; 

FUNCTION B2C ( P_BLOB BLOB ) RETURN CLOB IS
      L_CLOB         CLOB;
      L_DEST_OFFSSET INTEGER := 1;
      L_SRC_OFFSSET  INTEGER := 1;
      L_LANG_CONTEXT INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
      L_WARNING      INTEGER;

BEGIN

      IF P_BLOB IS NULL THEN
         RETURN NULL;
      END IF;

      DBMS_LOB.CREATETEMPORARY(LOB_LOC => L_CLOB
                              ,CACHE   => FALSE);

      DBMS_LOB.CONVERTTOCLOB(DEST_LOB     => L_CLOB
                            ,SRC_BLOB     => P_BLOB
                            ,AMOUNT       => DBMS_LOB.LOBMAXSIZE
                            ,DEST_OFFSET  => L_DEST_OFFSSET
                            ,SRC_OFFSET   => L_SRC_OFFSSET
                            ,BLOB_CSID    => DBMS_LOB.DEFAULT_CSID
                            ,LANG_CONTEXT => L_LANG_CONTEXT
                            ,WARNING      => L_WARNING);

      RETURN L_CLOB;

END B2C;


FUNCTION CLEAR_PARAMETRO ( PRM_PARAMETROS VARCHAR2 DEFAULT NULL ) RETURN CLOB IS
    
	WS_PARAMETROS    LONG;
	WS_PARAMETROS_F  LONG;
	WS_COUNT         NUMBER;
	
	BEGIN

		IF PRM_PARAMETROS <> '1|1' AND SUBSTR(PRM_PARAMETROS,1,3) = '1|1' THEN
	        IF SUBSTR(PRM_PARAMETROS,1,4)='1|1|' THEN
		        WS_PARAMETROS := SUBSTR(PRM_PARAMETROS,5,LENGTH(PRM_PARAMETROS));
			ELSE
		        WS_PARAMETROS := SUBSTR(PRM_PARAMETROS,4,LENGTH(PRM_PARAMETROS));
			END IF;
		ELSE
			WS_PARAMETROS := PRM_PARAMETROS;
		END IF;

		IF PRM_PARAMETROS <> '1|1' AND SUBSTR(PRM_PARAMETROS,1,6) = '1|11|1' THEN
	        WS_PARAMETROS := SUBSTR(PRM_PARAMETROS,8,LENGTH(PRM_PARAMETROS));
		END IF;

		WS_PARAMETROS := WS_PARAMETROS||'|';

		WS_PARAMETROS := TRIM(REPLACE(WS_PARAMETROS,'||','|'));

		IF NVL(TRIM(WS_PARAMETROS),'%X%')='%X%' THEN
		    WS_PARAMETROS := '1|1';
		END IF;
		
		WS_COUNT := 0;
		
		FOR I IN(SELECT DISTINCT CD_COLUNA, CD_CONTEUDO, CD_CONDICAO FROM TABLE(FUN.VPIPE_PAR(WS_PARAMETROS))) LOOP
		    IF WS_COUNT = 0 THEN
			    WS_PARAMETROS_F := I.CD_COLUNA||'|'||I.CD_CONDICAO||I.CD_CONTEUDO; 
			ELSE
			    WS_PARAMETROS_F := WS_PARAMETROS_F||'|'||I.CD_COLUNA||'|'||I.CD_CONDICAO||I.CD_CONTEUDO; 
			END IF;
			WS_COUNT := WS_COUNT+1;
		END LOOP;
	
    RETURN(WS_PARAMETROS_F);
END CLEAR_PARAMETRO;


FUNCTION CHECK_SESSION RETURN VARCHAR2 AS

      WS_LOCAL        OWA_COOKIE.COOKIE;
      WS_RETORNO      VARCHAR2(40);
      WS_COUNT        NUMBER;

BEGIN

    BEGIN
        UPDATE ACTIVE_SESSIONS
        SET STATUS='I'
        WHERE STATUS='A' AND DT_ATIVIDADE < (SYSDATE-((1/1440)*30));
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;

    BEGIN
        WS_LOCAL := OWA_COOKIE.GET('UPQ_SESSION_CHECK');

        IF  WS_LOCAL.VALS.FIRST IS NULL THEN
            WS_RETORNO := 'OK';
        ELSE
            SELECT COUNT(*) INTO WS_COUNT 
            FROM   ACTIVE_SESSIONS
            WHERE  USUARIO = GBL.GETUSUARIO AND
                STATUS='A';
            IF  WS_COUNT = 0 THEN
                WS_RETORNO := 'NO_S';
            ELSE
                WS_RETORNO := 'OK';
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            WS_RETORNO := 'NO_S';
    END;

   RETURN(WS_RETORNO);

END CHECK_SESSION;

FUNCTION SEND_ID ( PRM_CLIENTE VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

  TYPE           TP_ARRAY IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  WS_ARRAY       TP_ARRAY;
  WS_COUNTER     INTEGER;

  WS_INDICE      VARCHAR2(1);
  WS_SESSION     VARCHAR2(2);
  WS_INDICE_FAKE VARCHAR2(1);
  WS_IMEI        VARCHAR2(30);
  WS_ORIGEM      VARCHAR2(30);



BEGIN

  WS_IMEI         := '01275600346'||SUBSTR(PRM_CLIENTE, 7, 3)||'3877';
  
  WS_ARRAY(0)     := 'QPWOLASJIE';
  WS_ARRAY(1)     := 'ESLWPQMZNB';
  WS_ARRAY(2)     := 'YTRUIELQCB';
  WS_ARRAY(3)     := 'RADIOSULTE';
  WS_ARRAY(4)     := 'RITALQWCVM';
  WS_ARRAY(5)     := 'ZMAKQOCJDE';
  WS_ARRAY(6)     := 'YTHEDJKSPQ';
  WS_ARRAY(7)     := 'PIRALEZOUT';
  WS_ARRAY(8)     := 'HJWPAXOQTI';
  WS_ARRAY(9)     := 'DFRTEOAPQX';

  WS_INDICE       := SUBSTR(TO_CHAR(SYSDATE,'SS'),2,1);

  SELECT  SUBSTR(WS_ARRAY(WS_INDICE),(TO_NUMBER(SUBSTR(SID,1,1))+1),1)||SUBSTR(WS_ARRAY(WS_INDICE),(TO_NUMBER(SUBSTR(SERIAL#,1,1))+1),1)
          INTO WS_SESSION
  FROM    V$SESSION
  WHERE   AUDSID  = SYS_CONTEXT('USERENV', 'SESSIONID');

  WS_INDICE_FAKE := ABS((TO_NUMBER(WS_INDICE)-TO_NUMBER(SUBSTR(TO_CHAR(SYSDATE,'SS'),1,1))));

  WS_IMEI := SUBSTR(WS_ARRAY(WS_INDICE_FAKE),(TO_NUMBER(SUBSTR(WS_IMEI,9, 1))+1),1)||
             SUBSTR(WS_ARRAY(WS_INDICE_FAKE),(TO_NUMBER(SUBSTR(WS_IMEI,10,1))+1),1)||
             SUBSTR(WS_ARRAY(WS_INDICE_FAKE),(TO_NUMBER(SUBSTR(WS_IMEI,11,1))+1),1);

  WS_INDICE_FAKE := SUBSTR(WS_ARRAY(2),(TO_NUMBER(SUBSTR(WS_INDICE_FAKE, 1,1)+1)),1);
  WS_INDICE      := SUBSTR(WS_ARRAY(1),(TO_NUMBER(SUBSTR(WS_INDICE,      1,1)+1)),1);

  RETURN(WS_IMEI||WS_SESSION||WS_INDICE||WS_INDICE_FAKE);

END SEND_ID;

FUNCTION CHECK_ID ( PRM_CHAVE VARCHAR2 DEFAULT NULL, PRM_CLIENTE VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

	TYPE TP_ARRAY IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
	WS_ARRAY TP_ARRAY;
	WS_COUNTER INTEGER;

	WS_INDICE      VARCHAR2(1);
	WS_INDICE_FAKE VARCHAR2(1);
	WS_SESSION     VARCHAR2(2);
	WS_CHECK_IMEI  VARCHAR2(3);
	WS_IMEI        VARCHAR2(30);

	WS_RETORNO     VARCHAR2(30);

BEGIN

    WS_IMEI     := '01275600346'||SUBSTR(PRM_CLIENTE, 7, 3)||'3877';

	WS_ARRAY(0) := 'QPWOLASJIE';
	WS_ARRAY(1) := 'ESLWPQMZNB';
	WS_ARRAY(2) := 'YTRUIELQCB';
	WS_ARRAY(3) := 'RADIOSULTE';
	WS_ARRAY(4) := 'RITALQWCVM';
	WS_ARRAY(5) := 'ZMAKQOCJDE';
	WS_ARRAY(6) := 'YTHEDJKSPQ';
	WS_ARRAY(7) := 'PIRALEZOUT';
	WS_ARRAY(8) := 'HJWPAXOQTI';
	WS_ARRAY(9) := 'DFRTEOAPQX';

	WS_INDICE := (INSTR(WS_ARRAY(1),SUBSTR(PRM_CHAVE,6,1)))-1;
	WS_INDICE_FAKE := (INSTR(WS_ARRAY(2),SUBSTR(PRM_CHAVE,7,1)))-1;

	WS_SESSION := (INSTR(WS_ARRAY(WS_INDICE), SUBSTR(PRM_CHAVE,4,1))-1) ||
	(INSTR(WS_ARRAY(WS_INDICE), SUBSTR(PRM_CHAVE,5,1))-1);

	WS_CHECK_IMEI := (INSTR(WS_ARRAY(WS_INDICE_FAKE),SUBSTR(PRM_CHAVE,1,1))-1) ||
	(INSTR(WS_ARRAY(WS_INDICE_FAKE),SUBSTR(PRM_CHAVE,2,1))-1) ||
	(INSTR(WS_ARRAY(WS_INDICE_FAKE),SUBSTR(PRM_CHAVE,3,1))-1);

	WS_INDICE := SUBSTR(TO_CHAR(SYSDATE,'SS'),2,1);
	WS_INDICE_FAKE := ABS((TO_NUMBER(WS_INDICE)-TO_NUMBER(SUBSTR(TO_CHAR(SYSDATE,'SS'),1,1))));

	WS_SESSION := SUBSTR(WS_ARRAY(ABS(ABS(WS_INDICE - WS_INDICE_FAKE))),(TO_NUMBER(SUBSTR(WS_SESSION,1,1))+1),1) ||
	SUBSTR(WS_ARRAY(ABS(ABS(WS_INDICE - WS_INDICE_FAKE))),(TO_NUMBER(SUBSTR(WS_SESSION,2,1))+1),1);

	WS_IMEI := SUBSTR(WS_ARRAY(WS_INDICE_FAKE),(TO_NUMBER(SUBSTR(WS_IMEI,12, 1))+1),1)||
	SUBSTR(WS_ARRAY(WS_INDICE_FAKE),(TO_NUMBER(SUBSTR(WS_IMEI,13, 1))+1),1)||
	SUBSTR(WS_ARRAY(WS_INDICE_FAKE),(TO_NUMBER(SUBSTR(WS_IMEI,14, 1))+1),1);

	WS_INDICE_FAKE := SUBSTR(WS_ARRAY(4),(TO_NUMBER(SUBSTR(WS_INDICE_FAKE, 1,1)+1)),1);
	WS_INDICE := SUBSTR(WS_ARRAY(5),(TO_NUMBER(SUBSTR(WS_INDICE, 1,1)+1)),1);

	IF WS_CHECK_IMEI <> SUBSTR(WS_IMEI,9,3) THEN
	WS_RETORNO := 'ERRO';
	ELSE
	WS_RETORNO := WS_IMEI||WS_SESSION||WS_INDICE||WS_INDICE_FAKE;
	END IF;

	RETURN(WS_RETORNO);

END CHECK_ID;


FUNCTION CHECK_TOKEN ( PRM_CHAVE VARCHAR2 DEFAULT NULL, PRM_CLIENTE VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

	TYPE TP_ARRAY IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
	WS_ARRAY TP_ARRAY;
	WS_COUNTER INTEGER;

	WS_INDICE      NUMBER;
	WS_INDICE_FAKE NUMBER;
	WS_SESSION     VARCHAR2(2);
	WS_CHECK_IMEI  VARCHAR2(3);
	WS_IMEI        VARCHAR2(30);
	WS_RETORNO     VARCHAR2(30);

BEGIN

    WS_IMEI     := '01275600346'||SUBSTR(PRM_CLIENTE, 7, 3)||'3877';
	
	WS_ARRAY(0) := 'QPWOLASJIE';
	WS_ARRAY(1) := 'ESLWPQMZNB';
	WS_ARRAY(2) := 'YTRUIELQCB';
	WS_ARRAY(3) := 'RADIOSULTE';
	WS_ARRAY(4) := 'RITALQWCVM';
	WS_ARRAY(5) := 'ZMAKQOCJDE';
	WS_ARRAY(6) := 'YTHEDJKSPQ';
	WS_ARRAY(7) := 'PIRALEZOUT';
	WS_ARRAY(8) := 'HJWPAXOQTI';
	WS_ARRAY(9) := 'DFRTEOAPQX';

	WS_INDICE := (INSTR(WS_ARRAY(5),SUBSTR(PRM_CHAVE,6,1)))-1;
	WS_INDICE_FAKE := (INSTR(WS_ARRAY(4),SUBSTR(PRM_CHAVE,7,1)))-1;

	WS_SESSION := (INSTR(WS_ARRAY(ABS(WS_INDICE - WS_INDICE_FAKE)), SUBSTR(PRM_CHAVE,4,1))-1) ||
	(INSTR(WS_ARRAY(ABS(WS_INDICE - WS_INDICE_FAKE)), SUBSTR(PRM_CHAVE,5,1))-1);

	WS_CHECK_IMEI := (INSTR(WS_ARRAY(WS_INDICE_FAKE),SUBSTR(PRM_CHAVE,1,1))-1) ||
	(INSTR(WS_ARRAY(WS_INDICE_FAKE),SUBSTR(PRM_CHAVE,2,1))-1) ||
	(INSTR(WS_ARRAY(WS_INDICE_FAKE),SUBSTR(PRM_CHAVE,3,1))-1);

	RETURN(WS_SESSION||WS_CHECK_IMEI);

END CHECK_TOKEN;


FUNCTION SHOWTAG ( PRM_OBJ VARCHAR2 DEFAULT NULL,
                   PRM_TAG VARCHAR2 DEFAULT NULL,
				   PRM_OUTRO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS
									 
	WS_TALK VARCHAR2(40) := 'talk';
	WS_COUNT NUMBER;

BEGIN
    CASE PRM_TAG
	WHEN 'excel' THEN
	SELECT COUNT(*) INTO WS_COUNT FROM USUARIOS WHERE USU_NOME = GBL.GETUSUARIO AND NVL(EXCEL_OUT, 'S') = 'S';
		IF WS_COUNT = 1 OR GBL.GETNIVEL = 'A' THEN
            RETURN '<span class="excel" title="'||FUN.LANG('Exportar para excel')||'"></span>';
		ELSE
		    RETURN '<span class="noexcel" title="'||FUN.LANG('Exportar para excel bloqueado')||'"></span>';
		END IF;
	WHEN 'post' THEN
	    RETURN '<span class="'||WS_TALK||'" title="Text-post"></span>';
    WHEN 'atrib' THEN
	    RETURN '<span class="size" title="'||FUN.LANG('Atributos')||'" ></span>';	
    WHEN 'remove' THEN
	    RETURN '<span class="removeobj" title="'||FUN.LANG('Excluir')||'" ></span>';		
    WHEN 'filter' THEN
        RETURN '<span class="filter" title="'||FUN.LANG('Filtros')||'"></span>';    	
	WHEN 'export' THEN
	    RETURN '<span class="page_'||PRM_OUTRO||'" title="'||FUN.LANG('Exportar em '||PRM_OUTRO||'')||'"></span>';									
	WHEN 'exportnew' THEN
	    RETURN '<span class="page_png" title="'||FUN.LANG('Exportar em PNG')||'"><a id="'||PRM_OBJ||'link" href="" download="grafico.jpg" style="height: inherit; width: inherit; float: left;"></a></span>';									
	WHEN 'star' THEN
	    RETURN '<span class="star" title="'||FUN.LANG('Alterar Destaque')||'"></span>';
	WHEN 'fav' THEN
        RETURN '<span title="'||FUN.LANG('Marcar objeto')||'" class="fav" onclick="var ident = document.getElementById('''||PRM_OBJ||''').parentNode.parentNode.parentNode.id; loading(); ajax(''fly'', ''favoritar'', ''prm_objeto='||REPLACE(PRM_OBJ, 'trlc', '')||'&prm_nome=''+document.getElementById(ident+''_ds'').innerHTML+''&prm_url=&prm_screen=''+document.getElementById(''current_screen'').value+''&prm_parametros=''+encodeURIComponent(document.getElementById(''par_''+ident).value)+''&prm_dimensao=''+encodeURIComponent(document.getElementById(''col_''+ident).value)+''&prm_medida=''+encodeURIComponent(document.getElementById(''agp_''+ident).value)+''&prm_pivot=''+encodeURIComponent(document.getElementById(''cup_''+ident).value)+''&prm_acao=incluir'', false); loading(); call(''obj_screen_count'', ''prm_screen=''+tela+''&prm_tipo=FAVORITOS'').then(function(resposta){ if(parseInt(resposta) > 0){ document.getElementById(''favoritos'').classList.remove(''inv''); } else { document.getElementById(''favoritos'').classList.add(''inv''); } });"><svg style="height: 16px; width: 16px;" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" 	 width="613.408px" height="613.408px" viewBox="0 0 613.408 613.408" style="enable-background:new 0 0 613.408 613.408;" 	 xml:space="preserve"> <g> 	<path d="M605.254,168.94L443.792,7.457c-6.924-6.882-17.102-9.239-26.319-6.069c-9.177,3.128-15.809,11.241-17.019,20.855 		l-9.093,70.512L267.585,216.428h-142.65c-10.344,0-19.625,6.215-23.629,15.746c-3.92,9.573-1.71,20.522,5.589,27.779 		l105.424,105.403L0.699,613.408l246.635-212.869l105.423,105.402c4.881,4.881,11.45,7.467,17.999,7.467 		c3.295,0,6.632-0.709,9.78-2.002c9.573-3.922,15.726-13.244,15.726-23.504V345.168l123.839-123.714l70.429-9.176 		c9.614-1.251,17.727-7.862,20.813-17.039C614.472,186.021,612.136,175.801,605.254,168.94z M504.856,171.985 		c-5.568,0.751-10.762,3.232-14.745,7.237L352.758,316.596c-4.796,4.775-7.466,11.242-7.466,18.041v91.742L186.437,267.481h91.68 		c6.757,0,13.243-2.669,18.04-7.466L433.51,122.766c3.983-3.983,6.569-9.176,7.258-14.786l3.629-27.696l88.155,88.114 		L504.856,171.985z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg></span>';
    ELSE
	    RETURN '';
	END CASE;

END SHOWTAG;

FUNCTION CHECK_VALUE ( PRM_VALOR VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 IS

BEGIN
    IF LENGTH(TRIM(PRM_VALOR)) = 0 THEN 
	    RETURN ''; 
	ELSE 
	    RETURN REPLACE('|'||TRIM(PRM_VALOR), '||', '|'); 
	END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN '';
END CHECK_VALUE;


FUNCTION PTG_TRANS ( PRM_TEXTO IN VARCHAR2 ) RETURN VARCHAR2 IS

WS_RETORNO VARCHAR2(32000);

BEGIN
  WS_RETORNO := TRANSLATE( PRM_TEXTO,
                    'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëü',
                    'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu');

  RETURN WS_RETORNO;

END PTG_TRANS;



FUNCTION EXCLUIR_DASH ( PRM_OBJETO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

BEGIN

    RETURN('<a class="fechardash" id="'||PRM_OBJETO||'fechar" title="'||FUN.LANG('Excluir')||'" onclick="" ontouchend="" onmouseup="if(confirm(TR_CE)){ document.getElementById('''||PRM_OBJETO||''').classList.remove(''movingarticle''); remover('''||PRM_OBJETO||''', ''excluir''); }">X</a>');

END EXCLUIR_DASH;


FUNCTION CHECK_ADMIN ( PRM_PERMISSAO VARCHAR2 DEFAULT NULL )  RETURN BOOLEAN AS
    WS_STATUS VARCHAR2(1) := 'N';
	WS_COUNT NUMBER;
BEGIN
    IF GBL.GETNIVEL = 'A' THEN
	    RETURN TRUE;
	ELSE
	
		SELECT COUNT(*) INTO WS_COUNT FROM ADMIN_OPTIONS WHERE USUARIO = GBL.GETUSUARIO AND PERMISSAO = PRM_PERMISSAO;

		IF WS_COUNT = 0 THEN
			RETURN FALSE;
		ELSE
			SELECT STATUS INTO WS_STATUS FROM ADMIN_OPTIONS WHERE USUARIO = GBL.GETUSUARIO AND PERMISSAO = PRM_PERMISSAO;
		
			IF WS_STATUS = 'S' THEN
				RETURN TRUE;
			ELSE
				RETURN FALSE;
			END IF;
		END IF;
	END IF;
END CHECK_ADMIN;


FUNCTION GET_SEQUENCE ( PRM_TABELA VARCHAR2 DEFAULT NULL,
                        PRM_COLUNA VARCHAR2 DEFAULT NULL ) RETURN NUMBER AS

    WS_RETORNO NUMBER;
    WS_CURSOR  NUMBER;
    WS_QUANT   NUMBER;
    WS_SQL     VARCHAR2(200);
    WS_SQL_R   NUMBER;
    WS_COUNT     NUMBER;
BEGIN

    




























    
    SELECT COUNT(*) INTO WS_COUNT FROM BI_SEQUENCE WHERE NM_TABELA = PRM_TABELA AND NM_COLUNA = PRM_COLUNA;

	IF WS_COUNT = 0 THEN
        
		
		WS_SQL := 'select nvl(max(to_number('||PRM_COLUNA||')), 0)+1 from '||PRM_TABELA||'';
		WS_CURSOR := DBMS_SQL.OPEN_CURSOR;
		DBMS_SQL.PARSE(WS_CURSOR, WS_SQL, DBMS_SQL.NATIVE);
		DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, 1, WS_RETORNO);
		WS_SQL_R := DBMS_SQL.EXECUTE(WS_CURSOR);
		WS_SQL_R := DBMS_SQL.FETCH_ROWS(WS_CURSOR);
		DBMS_SQL.COLUMN_VALUE(WS_CURSOR, 1, WS_RETORNO);
		DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
		
		
		INSERT INTO BI_SEQUENCE (NM_TABELA, NM_COLUNA, SEQUENCIA) VALUES ( PRM_TABELA, PRM_COLUNA,  WS_RETORNO);
		COMMIT;
	ELSE

		SELECT SEQUENCIA+1 INTO WS_RETORNO FROM BI_SEQUENCE 
		WHERE NM_TABELA = PRM_TABELA AND NM_COLUNA = PRM_COLUNA
		FOR UPDATE OF SEQUENCIA;

	END IF;

    RETURN WS_RETORNO;

EXCEPTION WHEN OTHERS THEN
    INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - GET_SEQUENCE', GBL.GETUSUARIO, 'ERRO');
    RETURN 1;
END GET_SEQUENCE;

FUNCTION ATTRIB_TEMPOREAL ( PRM_ATRIB VARCHAR2 DEFAULT NULL, 
	                        PRM_OBJ   VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2

AS

    WS_SCRIP_EFEITO VARCHAR2(2000);
    WS_CONDICAO     VARCHAR2(80);

BEGIN

    CASE PRM_ATRIB
        WHEN 'DASH_MARGIN' THEN
            WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||''').style.setProperty(''margin'', this.value);';
        WHEN 'ALIGN_TIT' THEN
            WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||'''+''_ds'').style.setProperty(''text-align'', this.value);';
        

		WHEN 'FONTE_TIT' THEN
		    
            
			    WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||'''+''_ds'').style.setProperty(''color'', this.value);';
			

		WHEN 'FUNDO_VALOR' THEN
		    
            IF TRIM(FUN.GETPROP(PRM_OBJ,'DEGRADE')) = 'N' THEN
                WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||''').style.setProperty(''background-color'', this.value);';
		    END IF;

		WHEN 'FUNDO_TIT' THEN
		    
            IF TRIM(FUN.GETPROP(PRM_OBJ,'DEGRADE')) = 'N' THEN
                WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||'''+''_ds'').style.setProperty(''background-color'', this.value);';
		    END IF;

		WHEN 'TIT_BGCOLOR' THEN
            
            IF TRIM(FUN.GETPROP(PRM_OBJ,'DEGRADE')) = 'S' THEN
                WS_CONDICAO := FUN.GETPROP(PRM_OBJ,'DEGRADE_TIPO')||'-gradient(''+this.value+'', '||FUN.GETPROP(PRM_OBJ,'BGCOLOR')||')';
                WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||'''+''_ds'').style.removeProperty(''background-color''); document.getElementById('''||PRM_OBJ||''').style.setProperty(''background'', '''||WS_CONDICAO||''');';

            ELSE
                WS_CONDICAO := 'this.value';
                WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||'''+''_ds'').style.setProperty(''background-color'', '''||WS_CONDICAO||''');';
            END IF;
            
        WHEN 'TIT_COLOR' THEN
            WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||'''+''_ds'').style.setProperty(''color'', this.value);';
        WHEN 'BGCOLOR' THEN
            
            IF TRIM(FUN.GETPROP(PRM_OBJ,'DEGRADE')) = 'S' THEN
                WS_CONDICAO := FUN.GETPROP(PRM_OBJ,'DEGRADE_TIPO')||'-gradient('||FUN.GETPROP(PRM_OBJ,'TIT_BGCOLOR')||', ''+this.value+'')';
            ELSE
                WS_CONDICAO := 'this.value';
            END IF;
     
            WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||''').style.setProperty(''background'', '''||WS_CONDICAO||''');';
		WHEN 'IMG_BGCOLOR' THEN
		    WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||''').querySelector(''.img_container'').children[0].style.setProperty(''background'', this.value);';
        WHEN 'BORDA_COR' THEN
            WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||''').style.setProperty(''border'', ''1px solid ''+this.value);';
		WHEN 'IMG_BORDA' THEN
            WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||''').querySelector(''.img_container'').children[0].style.setProperty(''border'', ''1px solid ''+this.value);';
        WHEN 'IMG_RADIUS' THEN
            WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||''').querySelector(''.img_container'').children[0].style.setProperty(''border-radius'', this.value.replace(''px'', '''')+''px'');';
		WHEN 'IMG_ALTURA' THEN
            WS_SCRIP_EFEITO := 'var valor = this.value; if(valor.indexOf(''%'') == -1 && valor.indexOf(''auto'') == -1){ valor.replace(''px'', '''')+''px''; } document.getElementById('''||PRM_OBJ||''').querySelector(''.img_container'').children[0].style.setProperty(''height'', valor);';
		WHEN 'IMG_LARGURA' THEN
            WS_SCRIP_EFEITO := 'var valor = this.value; if(valor.indexOf(''%'') == -1 && valor.indexOf(''auto'') == -1){ valor.replace(''px'', '''')+''px''; } document.getElementById('''||PRM_OBJ||''').querySelector(''.img_container'').children[0].style.setProperty(''width'', valor);';
		WHEN 'NO_RADIUS' THEN
            WS_SCRIP_EFEITO := 'if(this.classList.contains(''checked'')){ document.getElementById('''||PRM_OBJ||''').style.setProperty(''border-radius'', ''0''); } else { document.getElementById('''||PRM_OBJ||''').style.setProperty(''border-radius'', ''7px 7px 0 0''); }';
        WHEN 'IMG_ESPACAMENTO' THEN
		    WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||''').querySelector(''.img_container'').children[0].style.setProperty(''padding'', this.value.replace(''px'', '''')+''px'');';
		WHEN 'DASH_MARGIN' THEN
            WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||''').style.setProperty(''margin'', this.value);';
        WHEN 'TIT_COLOR' THEN
            WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||'''+''_ds'').style.setProperty(''color'', this.value);';
        WHEN 'COLOR' THEN
            WS_SCRIP_EFEITO := 'if(document.getElementById(''valor_''+'''||PRM_OBJ||''')){ document.getElementById(''valor_''+'''||PRM_OBJ||''').style.setProperty(''color'', this.value); } if(document.getElementById('''||PRM_OBJ||'_vl'')){ document.getElementById('''||PRM_OBJ||'_vl'').style.setProperty(''color'', this.value); } if(document.getElementById('''||PRM_OBJ||'_mt'')){ document.getElementById('''||PRM_OBJ||'_mt'').style.setProperty(''color'', this.value); }';
        WHEN 'TIT_FONT' THEN
            WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||'_ds'').style.setProperty(''font-family'', this.value);';
        WHEN 'FONT' THEN
            WS_SCRIP_EFEITO := 'document.getElementById(''valor_'||PRM_OBJ||''').style.setProperty(''font-family'', this.value);';
        WHEN 'TIT_SIZE' THEN
            WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||'_ds'').style.setProperty(''font-size'', this.value);';
        WHEN 'SIZE' THEN
            WS_SCRIP_EFEITO := 'if(document.getElementById(''valor_''+'''||PRM_OBJ||''')){ document.getElementById(''valor_'||PRM_OBJ||''').style.setProperty(''font-size'', this.value); } if(document.getElementById('''||PRM_OBJ||'_vl'')){ document.getElementById('''||PRM_OBJ||'_vl'').style.setProperty(''font-size'', this.value); }';
        WHEN 'TIT_BOLD' THEN
            WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||'_ds'').style.setProperty(''font-weight'', this.value);';
        WHEN 'BOLD' THEN
            WS_SCRIP_EFEITO := 'document.getElementById(''valor_'||PRM_OBJ||''').style.setProperty(''font-weight'', this.value);';
        WHEN 'IT' THEN
            WS_SCRIP_EFEITO := 'document.getElementById(''valor_'||PRM_OBJ||''').style.setProperty(''font-style'', this.value);';
        WHEN 'TIT_IT' THEN
            WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||'_ds'').style.setProperty(''font-style'', this.value);';
        WHEN 'ALTURA' THEN
            WS_SCRIP_EFEITO := 'resizeObj(this, '''||PRM_OBJ||''', ''height'');';
            
        WHEN 'LARGURA' THEN
            WS_SCRIP_EFEITO := 'resizeObj(this, '''||PRM_OBJ||''', ''width'');';
            
        WHEN 'BORDA_COR' THEN
            WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||''').style.setProperty(''border'', ''1px solid ''+this.value);';
        WHEN 'DEGRADE_TIPO' THEN
        
            IF TRIM(FUN.GETPROP(PRM_OBJ,'DEGRADE')) = 'S' THEN
                WS_CONDICAO := '''+this.value+''-gradient('||FUN.GETPROP(PRM_OBJ,'TIT_BGCOLOR')||', '||FUN.GETPROP(PRM_OBJ,'BGCOLOR')||')';
                WS_SCRIP_EFEITO := 'document.getElementById('''||PRM_OBJ||'''+''_ds'').style.removeProperty(''background-color''); document.getElementById('''||PRM_OBJ||''').style.setProperty(''background'', '''||WS_CONDICAO||''');';
            END IF;
		WHEN 'TOTAL_GERAL_TEXTO' THEN
		    WS_SCRIP_EFEITO := 'if(this.value.length > 0 ){ document.getElementById('''||PRM_OBJ||'_FIXED-N'').value = 999; document.getElementById('''||PRM_OBJ||'_FIXED-N'').children[0].setAttribute(''readonly'', true); document.getElementById('''||PRM_OBJ||'_FIXED-N'').children[0].classList.add(''readonly''); } else { document.getElementById('''||PRM_OBJ||'_FIXED-N'').children[0].removeAttribute(''readonly''); document.getElementById('''||PRM_OBJ||'_FIXED-N'').children[0].classList.remove(''readonly''); }';

    ELSE
            WS_SCRIP_EFEITO := '';
    END CASE;
    
    RETURN WS_SCRIP_EFEITO;
    
END ATTRIB_TEMPOREAL;


FUNCTION ERROR_RESPONSE ( PRM_ERROR VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

    WS_RETORNO VARCHAR2(400);
	WS_COUNT NUMBER;

BEGIN

    WS_RETORNO := PRM_ERROR;

    SELECT REGEXP_COUNT(PRM_ERROR, 'ORA-') INTO WS_COUNT FROM DUAL;

    FOR I IN 1..WS_COUNT LOOP

		IF INSTR(PRM_ERROR, 'ORA-00933') <> 0 THEN
			WS_RETORNO := WS_RETORNO||'ORA-00933: COMANDO N&Atilde;O ENCERRADO ADEQUADAMENTE! ';
		END IF;
		
		IF INSTR(PRM_ERROR, 'ORA-23538') <> 0 THEN
			WS_RETORNO := WS_RETORNO||'ORA-23538: N&Atilde;O PODE USAR REFRESH EM UMA VIEW MATERIALIZADA COM BLOQUEIO DE REFRESH! ';
		END IF;
		
		IF INSTR(PRM_ERROR, 'ORA-06510') <> 0 THEN
			WS_RETORNO := WS_RETORNO||'ORA-06510: EXCEPTION N&Atilde;O TRATADA! ';
		END IF;
		
		IF INSTR(PRM_ERROR, 'ORA-00920') <> 0 THEN
			WS_RETORNO := WS_RETORNO||'ORA-00920: OPERADOR INV&Aacute;LIDO! ';
		END IF;
		
		IF INSTR(PRM_ERROR, 'ORA-01476') <> 0 THEN
			WS_RETORNO := WS_RETORNO||'ORA-01476: DIVISOR COM ZERO! ';
		END IF;
		
		IF INSTR(PRM_ERROR, 'ORA-06512') <> 0 AND INSTR(PRM_ERROR, 'DWU.FCL') <> 0 THEN
			WS_RETORNO := WS_RETORNO||'ORA-06512: ERRO DE PROCESSO! ';
		END IF;
	
	END LOOP;
	
	RETURN WS_RETORNO;

END ERROR_RESPONSE;

FUNCTION VPIPE_ORDER ( PRM_ENTRADA VARCHAR2,
                       PRM_DIVISAO VARCHAR2 DEFAULT '|' ) RETURN TAB_PIPE PIPELINED AS

   WS_BINDN      NUMBER;
   WS_TEXTO      VARCHAR2(12000);
   WS_NM_VAR      VARCHAR2(12000);
   WS_FLAG         CHAR(1);
   WS_COUNT      NUMBER;

BEGIN

   WS_FLAG  := 'N';
   WS_BINDN := 0;
   WS_TEXTO := PRM_ENTRADA;
   WS_COUNT := 0;


   LOOP
       IF  WS_FLAG = 'Y' THEN
           EXIT;
       END IF;
	   WS_COUNT := WS_COUNT+1;

       IF  NVL(INSTR(WS_TEXTO,PRM_DIVISAO),0) = 0 THEN
      WS_FLAG  := 'Y';
      WS_NM_VAR := WS_TEXTO;
       ELSE
      WS_NM_VAR := SUBSTR(WS_TEXTO, 1 ,INSTR(WS_TEXTO,PRM_DIVISAO)-1);
      WS_TEXTO  := SUBSTR(WS_TEXTO, LENGTH(WS_NM_VAR||PRM_DIVISAO)+1, LENGTH(WS_TEXTO));
       END IF;

       WS_BINDN := WS_BINDN + 1;
       PIPE ROW (PIPE_ORDER(WS_NM_VAR, WS_COUNT));

   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      PIPE ROW(PIPE_ORDER(SQLERRM||'=RET_LIST', WS_COUNT));

END VPIPE_ORDER;

FUNCTION AV_COLUMNS ( PRM_OBJ        VARCHAR2 DEFAULT NULL,
                      PRM_SCREEN     VARCHAR2 DEFAULT NULL,
					  PRM_CONDICOES  VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

   WS_TIPO        VARCHAR2(80);
   WS_VISAO       VARCHAR2(80);
   WS_TABELA      VARCHAR2(80);
   WS_DIMENSAO    VARCHAR2(800);
   WS_MEDIDA      VARCHAR2(800);
   WS_FILTRO      VARCHAR2(1600);
   WS_AGRUP       VARCHAR2(800);
   WS_COLUP       VARCHAR2(800);
   WS_COUNT       NUMBER;
   

BEGIN

    SELECT CD_MICRO_VISAO INTO WS_VISAO FROM PONTO_AVALIACAO WHERE CD_PONTO = PRM_OBJ;
    SELECT NM_TABELA INTO WS_TABELA FROM MICRO_VISAO WHERE NM_MICRO_VISAO = WS_VISAO;

    SELECT COUNT(*) INTO WS_COUNT FROM MICRO_QUBE WHERE NM_MICRO_VISAO = WS_TABELA;
	
	SELECT TP_OBJETO INTO WS_TIPO FROM OBJETOS WHERE CD_OBJETO = PRM_OBJ;

    IF WS_COUNT <> 0 THEN

        SELECT NVL(CS_COLUNA, PARAMETROS), CS_AGRUPADOR, CS_COLUP,
        (SELECT LISTAGG(CD_COLUNA, '|')  WITHIN GROUP (ORDER BY CD_COLUNA) FROM FILTROS WHERE CD_OBJETO = PRM_OBJ)||'|'||
        (SELECT LISTAGG(CD_COLUNA, '|')  WITHIN GROUP (ORDER BY CD_COLUNA) FROM FILTROS WHERE CD_OBJETO = PRM_SCREEN)||'|'||
        (SELECT LISTAGG(CD_COLUNA, '|')  WITHIN GROUP (ORDER BY CD_COLUNA) FROM FLOAT_FILTER_ITEM FFI WHERE SCREEN = PRM_SCREEN AND (FFI.CD_COLUNA = CS_COLUNA OR FFI.CD_COLUNA = CS_AGRUPADOR OR FFI.CD_COLUNA = CS_COLUP OR FFI.CD_COLUNA = PARAMETROS))
        INTO WS_DIMENSAO, WS_AGRUP, WS_COLUP, WS_FILTRO
        FROM PONTO_AVALIACAO T1
        WHERE CD_PONTO = PRM_OBJ;
		
		IF WS_TIPO <> 'VALOR' THEN
		    WS_MEDIDA := FUN.CONV_TEMPLATE(WS_VISAO, WS_AGRUP)||'|'||WS_COLUP;
		ELSE
		    WS_MEDIDA := WS_AGRUP||'|'||WS_COLUP;
		END IF;
		
		WS_FILTRO := REPLACE(WS_FILTRO||'|'||PRM_CONDICOES, '||', '|');
		
		RETURN FUN.GET_QDATA(FUN.TEST_COLUMNS(WS_DIMENSAO, WS_TABELA, WS_VISAO), FUN.TEST_COLUMNS(WS_MEDIDA, WS_TABELA, WS_VISAO), FUN.TEST_COLUMNS(WS_FILTRO, WS_TABELA, WS_VISAO), WS_VISAO);

    ELSE

        RETURN WS_TABELA;

    END IF;

END AV_COLUMNS;

FUNCTION TEST_COLUMNS ( PRM_VALOR  VARCHAR2 DEFAULT NULL,
                        PRM_TABELA VARCHAR2 DEFAULT NULL,
						PRM_VISAO  VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

    WS_COMBINADO VARCHAR2(12000);

BEGIN

    SELECT LISTAGG(COLUNA, '|')  WITHIN GROUP (ORDER BY COLUNA) INTO WS_COMBINADO FROM (
            SELECT COLUMN_NAME AS COLUNA, 
            (
              SELECT SUM(INSTR(FUN.GFORMULA2(UPPER(PRM_VISAO), COLUMN_VALUE), COLUMN_NAME)) 
              FROM TABLE((FUN.VPIPE(REPLACE(PRM_VALOR, '||', '|')))) WHERE 
              COLUMN_VALUE IN (SELECT CD_COLUNA FROM MICRO_COLUNA WHERE CD_MICRO_VISAO = PRM_VISAO) AND COLUMN_VALUE IS NOT NULL
			) AS DISPONIVEL 
            FROM ALL_TAB_COLUMNS 
            WHERE TABLE_NAME = PRM_TABELA
        ) WHERE DISPONIVEL > 0;
		
	RETURN WS_COMBINADO;
		
END TEST_COLUMNS;



















FUNCTION GET_QDATA ( PRM_DIMENSOES       VARCHAR2   DEFAULT NULL,
                     PRM_MEDIDAS         VARCHAR2   DEFAULT NULL,
                     PRM_FILTROS         VARCHAR2   DEFAULT NULL,
                     PRM_MICRO_VISAO     VARCHAR2   DEFAULT NULL ) RETURN VARCHAR2 AS

    WS_RETORNO         VARCHAR2(8000);
	WS_RETORNO_ANT     VARCHAR2(8000);
    WS_COLUNAS         VARCHAR2(8000);
    WS_DIMMED          VARCHAR2(8000);
    WS_CONDICOES       VARCHAR2(4000);
    WS_TABELA_ORIGINAL VARCHAR2(4000);
	WS_QUERY_ANT       VARCHAR2(4000);

    WS_TABELA          VARCHAR2(4000);
    WS_COUNT           NUMBER := 0;
    WS_COL_TESTE       VARCHAR2(2000);
    WS_TP_COLUNA       VARCHAR2(2000);
    WS_VIRGULA         VARCHAR2(1);
    WS_AND             VARCHAR2(5);
    WS_NO_EXEC         EXCEPTION;
	WS_NEXT            EXCEPTION;
	
	
	CURSOR CRS_QUBOS IS
	SELECT NM_TABELA FROM MICRO_QUBE 
	WHERE NM_MICRO_VISAO = PRM_MICRO_VISAO;
	WS_QUBO CRS_QUBOS%ROWTYPE;

BEGIN

    SELECT NM_TABELA INTO WS_TABELA_ORIGINAL
			  FROM MICRO_VISAO WHERE NM_MICRO_VISAO=PRM_MICRO_VISAO;


    WS_RETORNO_ANT := WS_TABELA_ORIGINAL;
	
	WS_COLUNAS := PRM_DIMENSOES||'|'||PRM_MEDIDAS||'|'||PRM_FILTROS;



    OPEN CRS_QUBOS;
        LOOP
	        FETCH CRS_QUBOS INTO WS_QUBO;
		    EXIT WHEN CRS_QUBOS%NOTFOUND;
			
		      
			  WS_COUNT := WS_COUNT+1;
			  
			  WS_TABELA := WS_QUBO.NM_TABELA;
			  
			  WS_DIMMED := '';
			  WS_VIRGULA := '';

			  


			  
			  BEGIN
			  
 
				  FOR VRF_COL IN (SELECT DISTINCT COLUMN_VALUE AS CD_COLUNA FROM TABLE(FUN.VPIPE(WS_COLUNAS)) WHERE COLUMN_VALUE IS NOT NULL) LOOP
						BEGIN
							 SELECT CD_COLUNA, TP_COLUNA INTO WS_COL_TESTE, WS_TP_COLUNA
							 FROM   COLUMNS_QDATA
							 WHERE  CD_TABELA = WS_TABELA AND 
								   CD_COLUNA = VRF_COL.CD_COLUNA
								   ORDER BY TP_COLUNA;
						EXCEPTION
							 WHEN OTHERS THEN 
							     WS_COL_TESTE := '%SEM_COLUNA%_UPQUERY';
							     
						END;

						IF  VRF_COL.CD_COLUNA = WS_COL_TESTE THEN
							NULL;
						
						
						END IF;

				  END LOOP;
				  
				  
				  FOR VRF_COL IN (SELECT DISTINCT COLUMN_VALUE AS CD_COLUNA FROM TABLE(FUN.VPIPE(WS_COLUNAS))  WHERE COLUMN_VALUE IS NOT NULL) LOOP
						BEGIN
							 SELECT CD_COLUNA, TP_COLUNA INTO WS_COL_TESTE, WS_TP_COLUNA
							 FROM   COLUMNS_QDATA
							 WHERE  CD_TABELA = WS_TABELA AND 
								   CD_COLUNA = VRF_COL.CD_COLUNA
								   ORDER BY TP_COLUNA;
						EXCEPTION
							 WHEN OTHERS THEN RAISE WS_NO_EXEC;
						END;

						WS_RETORNO := 'select ';

						IF  VRF_COL.CD_COLUNA = WS_COL_TESTE THEN
							IF  WS_TP_COLUNA = 'DIM' THEN
								WS_DIMMED := WS_DIMMED||WS_VIRGULA||CHR(13)||' '||VRF_COL.CD_COLUNA||' as '||VRF_COL.CD_COLUNA;
								WS_VIRGULA := ',';
							ELSE
								WS_DIMMED := WS_DIMMED||WS_VIRGULA||CHR(13)||' '||VRF_COL.CD_COLUNA||' as '||VRF_COL.CD_COLUNA;
								WS_VIRGULA := ',';
							END IF;
						ELSE
							NULL;
						END IF;

				  END LOOP;

				  WS_RETORNO := WS_RETORNO||WS_DIMMED||' from '||WS_TABELA||CHR(13);
				  WS_RETORNO := WS_RETORNO||' where '||CHR(13);

				  FOR VRF_NULL IN (
					SELECT 'UGRP_'||CD_COLUNA AS CD_COLUNA, ' = 0 ' AS TIPO, TP_COLUNA FROM COLUMNS_QDATA WHERE CD_TABELA = WS_TABELA AND CD_COLUNA    IN (SELECT DISTINCT COLUMN_VALUE AS CD_COLUNA FROM TABLE(FUN.VPIPE(WS_COLUNAS)) WHERE COLUMN_VALUE IS NOT NULL)
					UNION ALL
					SELECT 'UGRP_'||CD_COLUNA AS  CD_COLUNA, ' = 1' AS TIPO, TP_COLUNA FROM COLUMNS_QDATA WHERE CD_TABELA = WS_TABELA AND CD_COLUNA NOT IN (SELECT DISTINCT COLUMN_VALUE AS CD_COLUNA FROM TABLE(FUN.VPIPE(WS_COLUNAS)) WHERE COLUMN_VALUE IS NOT NULL)
				  )
				  
				  LOOP
					  IF VRF_NULL.TP_COLUNA = 'DIM' THEN
						  WS_RETORNO := WS_RETORNO||WS_AND||CHR(13)||VRF_NULL.CD_COLUNA||VRF_NULL.TIPO;
						  WS_AND := ' and ';
					  END IF;
				  END LOOP;

				  WS_RETORNO := '( '||WS_RETORNO||' )';

				  WS_RETORNO_ANT := WS_RETORNO;
				  
				  EXIT;

		    EXCEPTION
			   
			    WHEN WS_NO_EXEC THEN
				    WS_RETORNO := WS_RETORNO_ANT;
				WHEN OTHERS THEN
					WS_RETORNO := WS_RETORNO_ANT;
		    END;

	    END LOOP;
    CLOSE CRS_QUBOS;


  RETURN(WS_RETORNO);

EXCEPTION WHEN OTHERS THEN
    RETURN(WS_TABELA_ORIGINAL);
END GET_QDATA;

FUNCTION CREATE_USER ( USERNAME         IN VARCHAR2, 
					   PASSWORD         IN VARCHAR2,
					   PRM_REFERENCIA   IN VARCHAR2 DEFAULT NULL,
					   PRM_EMAIL        IN VARCHAR2,
					   PRM_COMPLETO     IN VARCHAR2  ) RETURN VARCHAR2 AS

   WS_NO_CREATE    EXCEPTION;
   WS_ERRO         EXCEPTION;
   WS_STATUS       VARCHAR2(50);
   WS_VRF          VARCHAR2(10);
   WS_COUNT_NET    NUMBER;

BEGIN

    WS_STATUS := 'OK';

    BEGIN
        BEGIN
            INSERT INTO USUARIOS (USU_NOME, USU_COMPLETO, USU_EMAIL, STATUS, EXCEL_OUT)
            VALUES ( USERNAME, PRM_COMPLETO, PRM_EMAIL, 'A', 'S' );

            insert into log_eventos values(sysdate, 'CRIACAO USUARIO', username, 'TELA', 'USUARIO', '01');

            WS_VRF := DIGESTPASSWORD(USERNAME, PASSWORD);
            INSERT INTO ROLES VALUES (USERNAME, 'DWU', 'ME');
            INSERT INTO ROLES VALUES (USERNAME, 'DWU', 'ONLY');
            INSERT INTO USER_NETWALL VALUES(USERNAME, 'LIVRE_01', 'L', '', 0, 24, 0, SYSDATE);

            IF  PRM_REFERENCIA IS NOT NULL THEN

                INSERT INTO USER_SCREENS (USUARIO, SCREEN, STATUS)
                SELECT USERNAME, T2.SCREEN, T2.STATUS FROM USER_SCREENS T2 WHERE T2.USUARIO = PRM_REFERENCIA;

                FOR I IN(SELECT MICRO_VISAO, CD_COLUNA, CONDICAO, CONTEUDO, LIGACAO FROM FILTROS WHERE CD_USUARIO = PRM_REFERENCIA AND TP_FILTRO = 'geral') LOOP
	                FCL.SETFILTRO(USERNAME, I.MICRO_VISAO, I.CD_COLUNA, I.CONDICAO, I.CONTEUDO, I.LIGACAO);
                END LOOP;

                INSERT INTO OBJECT_RESTRICTION (USUARIO, CD_OBJETO, ST_RESTRICAO, DT_LAST)
                SELECT USERNAME, T2.CD_OBJETO, T2.ST_RESTRICAO, SYSDATE FROM OBJECT_RESTRICTION T2 WHERE T2.USUARIO = PRM_REFERENCIA;

                INSERT INTO PARAMETRO_USUARIO (CD_USUARIO, CD_PADRAO, CONTEUDO, PRE_LOAD) 
                SELECT USERNAME, T2.CD_PADRAO, T2.CONTEUDO, '' FROM PARAMETRO_USUARIO T2 WHERE CD_USUARIO = PRM_REFERENCIA;

                INSERT INTO ROLES (CD_USUARIO, CD_ROLE, TIPO)
                SELECT USERNAME, T2.CD_ROLE, T2.TIPO FROM ROLES T2 WHERE CD_USUARIO = PRM_REFERENCIA;

                INSERT INTO COLUMN_RESTRICTION (USUARIO, CD_MICRO_VISAO, CD_COLUNA, ST_RESTRICAO, DT_LAST)
                SELECT USERNAME, T2.CD_MICRO_VISAO, T2.CD_COLUNA, T2.ST_RESTRICAO, SYSDATE FROM COLUMN_RESTRICTION T2 WHERE T2.USUARIO = PRM_REFERENCIA;

                FOR I IN(SELECT CD_OBJETO, CD_COLUNA, CONDICAO, CONTEUDO, COR_FUNDO, COR_FONTE, TIPO_DESTAQUE, PRIORIDADE FROM DESTAQUE WHERE CD_USUARIO = PRM_REFERENCIA) LOOP
                    FCL.SETDESTAQUE(USERNAME, I.CD_OBJETO, I.CD_COLUNA, I.CONDICAO, I.CONTEUDO, I.COR_FUNDO, I.COR_FONTE, I.TIPO_DESTAQUE, I.PRIORIDADE);
                END LOOP;
                
                BEGIN
                  SELECT COUNT(*) INTO WS_COUNT_NET FROM USER_NETWALL WHERE USUARIO = USERNAME;
                    IF WS_COUNT_NET > 0 THEN
                        DELETE USER_NETWALL WHERE USUARIO = USERNAME;
                        
                    END IF;
                        INSERT INTO USER_NETWALL (USUARIO, NOME_REGRA, TIPO_REGRA, NET_ADDRESS, HR_INICIO, HR_FINAL, DIA_SEMANA, DT_REGRA)
                        SELECT USERNAME, T2.NOME_REGRA, T2.TIPO_REGRA, T2.NET_ADDRESS, T2.HR_INICIO, T2.HR_FINAL, T2.DIA_SEMANA, T2.DT_REGRA FROM USER_NETWALL T2 WHERE USUARIO = PRM_REFERENCIA;
                EXCEPTION
                  WHEN OTHERS THEN
                    rollback;
                    INSERT INTO BI_LOG_SISTEMA VALUES (SYSDATE,'ERRO AO COPIAR O NETWALL','DWU','ERRO');    
                    
                END;

            END IF;

            COMMIT;

        EXCEPTION WHEN OTHERS THEN
            ROLLBACK;
            WS_STATUS := 'ERRO';
		    RAISE WS_ERRO;
        END;

    EXCEPTION
        WHEN WS_NO_CREATE THEN
            WS_STATUS := 'ERRO';
	
        WHEN OTHERS THEN
            EXECUTE IMMEDIATE 'drop user "'||USERNAME||'"';
            WS_STATUS := 'ERRO';
    END;

    RETURN(WS_STATUS);

EXCEPTION 
    WHEN WS_ERRO THEN
        RETURN(WS_STATUS);
    WHEN OTHERS THEN
        RETURN(WS_STATUS);
END;

FUNCTION REMOVE_USER ( PRM_USUARIO VARCHAR2 ) RETURN VARCHAR2 AS

    WS_COUNT NUMBER;
    WS_USER NUMBER;
	WS_EXCEPTION EXCEPTION;

	WS_CMD VARCHAR2(8000);
  
BEGIN

    WS_COUNT := 0;

    BEGIN

        insert into log_eventos values(sysdate, 'EXCLUSAO USUARIO', prm_usuario, 'TELA', 'USUARIO', '01');
        
        DELETE FROM USUARIOS
        WHERE TRIM(USU_NOME) = PRM_USUARIO AND ROWNUM = 1;
        
        DELETE FROM FILTROS
        WHERE TRIM(CD_USUARIO) = PRM_USUARIO AND TP_FILTRO = 'geral';
        
        DELETE FROM USER_SCREENS
        WHERE TRIM(USUARIO) = PRM_USUARIO;
        
        DELETE FROM FILTROS
        WHERE TRIM(CD_USUARIO) = PRM_USUARIO AND TP_FILTRO = 'objeto';
        
        DELETE FROM DESTAQUE
        WHERE TRIM(CD_USUARIO) = PRM_USUARIO;
        
        DELETE FROM OBJECT_RESTRICTION
        WHERE TRIM(USUARIO) = PRM_USUARIO;
        
        DELETE FROM USER_NETWALL
        WHERE TRIM(USUARIO) = PRM_USUARIO;
        
        DELETE FROM COLUMN_RESTRICTION
        WHERE TRIM(USUARIO) = PRM_USUARIO;
        
        DELETE FROM ADMIN_OPTIONS
        WHERE TRIM(USUARIO) = PRM_USUARIO;

        DELETE FROM GUSERS_ITENS
        WHERE TRIM(CD_USUARIO) = PRM_USUARIO;
        
        DELETE FROM ROLES               
        WHERE TRIM(CD_USUARIO)  = PRM_USUARIO;

        DELETE FROM PARAMETRO_USUARIO    
        WHERE TRIM(CD_USUARIO) = PRM_USUARIO;

        DELETE FROM OBJECT_ATTRIB       
        WHERE TRIM(OWNER)       = PRM_USUARIO;

        DELETE FROM FLOAT_FILTER_ITEM   
        WHERE TRIM(CD_USUARIO)  = PRM_USUARIO;

        RETURN 'OK';
 
    EXCEPTION WHEN OTHERS THEN
        rollback;
        insert into bi_log_sistema values (sysdate, 'N&atilde;o foi poss&iacute;vel excluir o usu&aacute; do sistema.', gbl.getUsuario, 'ERRO');
		commit;	
        RAISE WS_EXCEPTION;
    END;
EXCEPTION 
    WHEN WS_EXCEPTION THEN

        RETURN 'ERRO';
    WHEN OTHERS THEN
        RETURN 'ERRO';
END REMOVE_USER;

FUNCTION CONVERTE( PRM_TEXTO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

    WS_CONVERTIDO VARCHAR2(4000);
	WS_CHARSET VARCHAR2(200);

BEGIN

    WS_CHARSET := FUN.RET_VAR('CHARSET');

    IF NVL(WS_CHARSET, 'AL32UTF8') <> 'AL32UTF8' THEN
	    
		BEGIN
		    SELECT CONVERT(PRM_TEXTO, WS_CHARSET, 'AL32UTF8') INTO WS_CONVERTIDO FROM DUAL;
			
		EXCEPTION WHEN OTHERS THEN
			WS_CONVERTIDO := PRM_TEXTO;
		END;

		RETURN WS_CONVERTIDO;
	ELSE
        RETURN PRM_TEXTO;
	END IF;

END CONVERTE;

FUNCTION CHECK_SCREEN_ACCESS ( PRM_SCREEN VARCHAR2 DEFAULT NULL, 
                               PRM_USUARIO VARCHAR2 DEFAULT NULL, 
                               PRM_ADMIN VARCHAR2 DEFAULT NULL ) RETURN NUMBER AS

    WS_COUNT   NUMBER;
    WS_USUARIO VARCHAR2(80);

BEGIN

    
    
    IF PRM_SCREEN <> 'DEFAULT' AND PRM_ADMIN <> 'A' THEN
        SELECT COUNT(*) INTO WS_COUNT FROM USER_SCREENS WHERE 
            (
                TRIM(USUARIO) = PRM_USUARIO AND
                (
                    TRIM(SCREEN) = TRIM(PRM_SCREEN) OR 
                    TRIM(SCREEN) IN (SELECT CD_GRUPO FROM GRUPOS_FUNCAO WHERE CD_GRUPO IN(SELECT CD_GRUPO FROM OBJETOS WHERE CD_OBJETO = TRIM(PRM_SCREEN)))
                )
            ) OR 
            (
                TRIM(USUARIO) IN (SELECT CD_GROUP FROM GUSERS_ITENS WHERE CD_USUARIO = PRM_USUARIO) AND
                (
                    TRIM(SCREEN) = TRIM(PRM_SCREEN) OR
                    TRIM(SCREEN) IN (SELECT CD_GRUPO FROM GRUPOS_FUNCAO WHERE CD_GRUPO IN(SELECT CD_GRUPO FROM OBJETOS WHERE CD_OBJETO = TRIM(PRM_SCREEN)))
                )
            ); 
    ELSE
        WS_COUNT := 1;
    END IF;
    RETURN WS_COUNT;

END CHECK_SCREEN_ACCESS;

FUNCTION NOMEOBJETO( PRM_OBJETO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

    WS_OBJETO VARCHAR2(120);

BEGIN

    WS_OBJETO := PRM_OBJETO;

    SELECT NM_OBJETO INTO WS_OBJETO FROM OBJETOS WHERE CD_OBJETO = PRM_OBJETO;

    RETURN WS_OBJETO;
EXCEPTION WHEN OTHERS THEN
    RETURN PRM_OBJETO;
END NOMEOBJETO;

FUNCTION USUARIO RETURN VARCHAR2 AS

BEGIN
    
    RETURN 'DWU';

END;

FUNCTION RANDOMCODE( PRM_TAMANHO NUMBER DEFAULT 10) RETURN VARCHAR2 AS 

    WS_CODE VARCHAR2(200);

BEGIN

    SELECT XMLAGG(XMLELEMENT("r", CH)).EXTRACT('//text()').GETSTRINGVAL() INTO WS_CODE FROM
    (
        SELECT DISTINCT FIRST_VALUE(CH) OVER (PARTITION BY LOWER(CH)) AS CH
        FROM (
            SELECT SUBSTR('abcdefghijklmnpqrstuvwxyzABCDEFGHIJKLMNPQRSTUVWXYZ123456789',
                LEVEL, 1) AS CH
            FROM DUAL 
            CONNECT BY LEVEL <= 59
            ORDER BY DBMS_RANDOM.VALUE
            )
        WHERE ROWNUM <= PRM_TAMANHO
    );

    RETURN WS_CODE;

END RANDOMCODE;

FUNCTION OBJCODE ( PRM_ALIAS VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 AS

    WS_CODIGO VARCHAR2(200);

BEGIN

     SELECT PRM_ALIAS||TRIM((SELECT SID FROM V$SESSION WHERE AUDSID = SYS_CONTEXT('userenv','sessionid'))||
    		(SELECT SERIAL# FROM V$SESSION WHERE AUDSID = SYS_CONTEXT('userenv','sessionid'))||
    		TO_CHAR(SYSDATE,'yymmddhhmiss')) INTO WS_CODIGO FROM DUAL;

    RETURN WS_CODIGO;

END OBJCODE;














































































FUNCTION DIGESTPASSWORD( PRM_USUARIO VARCHAR2, PRM_PASSWORD VARCHAR2 ) RETURN VARCHAR2 AS

    WS_COUNT NUMBER := 0;

BEGIN

    --UPDATE USUARIOS 
    --SET PASSWORD = LTRIM(TO_CHAR(DBMS_UTILITY.GET_HASH_VALUE(UPPER(TRIM(PRM_USUARIO))||'/'||UPPER(TRIM(PRM_PASSWORD)), 1000000000, POWER(2,30) ), RPAD( 'X',29,'X')||'X'))||LTRIM( TO_CHAR(DBMS_UTILITY.GET_HASH_VALUE(UPPER(TRIM(FUN.RET_VAR('CLIENTE'))), 100000000, POWER(2,30) ), RPAD( 'X',29,'X')||'X' ) )
    --WHERE UPPER(TRIM(USU_NOME)) = UPPER(TRIM(PRM_USUARIO));
    --WS_COUNT := SQL%ROWCOUNT;

    -- Retirado o código do cliente da senha, o código do cliente foi retirado da senha para permitir a alteração do código de cliente sem prejudicar o acesso dos usuários
    update usuarios 
       set password = ltrim(to_char(dbms_utility.get_hash_value(upper(trim(prm_usuario))||'/'||upper(trim(prm_password)), 1000000000, power(2,30) ), rpad( 'X',29,'X')||'X'))     
     where upper(trim(usu_nome)) = upper(trim(prm_usuario));
    ws_count := SQL%ROWCOUNT;

    IF WS_COUNT = 1 THEN
        insert into log_eventos values(sysdate, 'ALTERACAO SENHA[digestPassword]', prm_usuario, 'TELA', 'USUARIO', '01');
        commit;
        RETURN 'Y';
    ELSE
        ROLLBACK;
        RETURN 'N';
    END IF;

EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    RETURN 'N';
END DIGESTPASSWORD;

FUNCTION TESTDIGESTEDPASSWORD( PRM_USUARIO VARCHAR2, PRM_PASSWORD VARCHAR2 ) RETURN VARCHAR2 AS

    WS_COUNT NUMBER := 0;
    WS_COUNT_SENHA NUMBER := 0;
    WS_VRF VARCHAR2(10) := 'N';
BEGIN
    -- Valida a senha sem o código do cliente, 
    select count(*) into ws_count 
      from usuarios
     where nvl(password, 'N/A') = ltrim(to_char(dbms_utility.get_hash_value(upper(trim(prm_usuario))||'/'||upper(trim(prm_password)), 1000000000, power(2,30) ), rpad( 'X',29,'X')||'X'))
       and upper(trim(usu_nome)) = upper(trim(prm_usuario));

    -- Valida a senha com o código do cliente (senhas antigas, criadas com o código do cliente)
    if ws_count = 0 then
        SELECT COUNT(*) INTO WS_COUNT 
          FROM USUARIOS
         WHERE PASSWORD = LTRIM(TO_CHAR(DBMS_UTILITY.GET_HASH_VALUE(UPPER(TRIM(PRM_USUARIO))||'/'||UPPER(TRIM(PRM_PASSWORD)), 1000000000, POWER(2,30) ), RPAD( 'X',29,'X')||'X'))||LTRIM( TO_CHAR(DBMS_UTILITY.GET_HASH_VALUE(UPPER(TRIM(FUN.RET_VAR('CLIENTE'))), 100000000, POWER(2,30) ), RPAD( 'X',29,'X')||'X' ) )
           AND upper(trim(usu_nome)) = upper(trim(prm_usuario));
    end if; 

    IF WS_COUNT <> 0 THEN
        RETURN 'Y';
    ELSE
        SELECT COUNT(*) INTO WS_COUNT_SENHA 
          FROM USUARIOS
         WHERE upper(trim(usu_nome)) = upper(trim(prm_usuario))
           and PASSWORD is NOT null;

        IF WS_COUNT_SENHA <> 0 THEN 
           RETURN 'N';
        ELSE    
            WS_VRF := PWD_VRF(PRM_USUARIO, PRM_PASSWORD);

            IF WS_VRF = 'Y' THEN

                WS_VRF := FUN.DIGESTPASSWORD(PRM_USUARIO, PRM_PASSWORD);
                COMMIT;
                RETURN WS_VRF;
            END IF;

            RETURN 'N';
        END IF;    
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN 'N';
END TESTDIGESTEDPASSWORD;



FUNCTION CONV_DATA( PRM_DATA VARCHAR2) RETURN DATE AS
W_DATA    DATE := NULL; 
BEGIN

    -- Se não for possível converter por nenhum dos formatos abaixo, a função deve retorar erro, o erro não deve ser tratado aqui na função 
    BEGIN
        W_DATA := TO_DATE(PRM_DATA,'DD/MM/YYYY HH24:MI:SS','NLS_DATE_LANGUAGE='||FUN.RET_VAR('LANG_DATE') ); 
    EXCEPTION WHEN OTHERS THEN 
        BEGIN
            W_DATA := TO_DATE(PRM_DATA,'DD/MM/YYYY HH24:MI:SS','NLS_DATE_LANGUAGE=AMERICAN');     -- Se não converteu pela linguagem parametrizada, tenta o formato Americano  
        EXCEPTION WHEN OTHERS THEN
            W_DATA := TO_DATE(PRM_DATA,'DD/MM/YYYY HH24:MI:SS','NLS_DATE_LANGUAGE=PORTUGUESE');     -- Se não converteu pela linguagem parametrizada, tenta o formato Portugues  
        END;    
    END; 
    W_DATA := TO_DATE(W_DATA); 
   
    RETURN(W_DATA);
END CONV_DATA; 


END FUN;