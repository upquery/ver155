-- >>>>>>>------------------------------------------------------------------------
-- >>>>>>> Aplicação:	CORE
-- >>>>>>> Por:		Upquery
-- >>>>>>> Data:	12/08/2020
-- >>>>>>> Pacote:	CORE
-- >>>>>>>------------------------------------------------------------------------
-- >>>>>>>------------------------------------------------------------------------
create or replace package  CORE  is

    FUNCTION MONTA_QUERY_DIRECT ( prm_micro_visao		    in  long	default null,
                                  prm_coluna		        in  long	default null,
                                  prm_condicoes             in  long	default null,
                                  prm_rp                    in  long	default null,
                                  prm_colup                 in  long	default null,
                                  prm_query_pivot           out long,
                                  prm_query_padrao          out DBMS_SQL.VARCHAR2a,
                                  prm_linhas                out number,
                                  prm_ncolumns              out DBMS_SQL.VARCHAR2_TABLE,
                                  prm_pvpull                out DBMS_SQL.VARCHAR2_TABLE,
                                  prm_agrupador             in  long,
                                  prm_mfiltro               out DBMS_SQL.VARCHAR2_TABLE,
                                  prm_objeto		        in  varchar2    default null,
                                    prm_ordem		            in  varchar2	default '1',
                                    prm_screen                in  long        default null,
                                    prm_cross                 in  varchar2 default null,
                                    prm_cab_cross             out varchar2,
                                    prm_self                  in varchar2 default null ) return varchar2;

    FUNCTION BIND_DIRECT (	prm_condicoes	 varchar2	default null,
						prm_cursor  	 number     default 0,
						prm_tipo		 varchar2	default null,
						prm_objeto		 varchar2	default null,
						prm_micro_visao	 varchar2	default null,
						prm_screen       varchar2   default null,
                        prm_no_having    varchar2   default 'S' ) return varchar2;

    FUNCTION DATA_DIRECT ( prm_micro_data    in  long	     default null,
				    	   prm_coluna		 in  long	     default null,
			    		   prm_query_padrao  out DBMS_SQL.VARCHAR2a,
				    	   prm_linhas		 out number,
				    	   prm_ncolumns	     out DBMS_SQL.VARCHAR2_TABLE,
				    	   prm_objeto		 in  varchar2    default null,
	                       prm_chave		 in  varchar2    default null,
			    		   prm_ordem		 in  varchar2    default null,
			    		   prm_screen        in  varchar2    default null,
				    	   prm_limite        in  number      default null,
			    		   prm_referencia    in  number      default 0,
			    		   prm_direcao       in  varchar2    default '>',
	                       prm_limite_final  out number,
						   prm_condicao      in varchar2   default 'semelhante',
						   prm_busca         in varchar2   default null,
	                       prm_count         in boolean    default false,
						   prm_acumulado     in varchar2 default null ) return varchar2;

    FUNCTION CDESC_SQL ( prm_tabela  char default null,
                         prm_coluna  char default null,   
                         prm_reverse boolean default false ) return varchar2 ;


    
end CORE;
