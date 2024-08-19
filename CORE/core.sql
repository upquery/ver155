set scan off
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
/

create or replace package body  CORE  is

    cursor crs_filtrog (  prm_condicoes varchar2, 
                          prm_micro_visao varchar2, 
                          prm_screen varchar2, 
                          prm_objeto varchar2, p_condicoes    varchar2,
                               p_micro_visao  varchar2,
                               p_cd_mapa      varchar2,
                               p_nr_item      varchar2,
                               p_cd_padrao    varchar2,
                               p_vpar         varchar2,
                               prm_usuario    varchar2 ) is

                               select distinct *
                               from (
							      select  'C'                                   as indice,
                                          'DWU'                                 as cd_usuario,
                                          trim(prm_micro_visao)                 as micro_visao,
                                          trim(cd_coluna)                       as cd_coluna,
                                          'DIFERENTE'                           as condicao,
                                          replace(trim(CONTEUDO), '$[NOT]', '') as conteudo,
                                          'and'                                 as ligacao,
                                          'float_filter_item'                   as tipo
                                   from   FLOAT_FILTER_ITEM
                                   where
                                        trim(cd_usuario) = prm_usuario and
                                        trim(screen) = trim(prm_screen) and
										instr(trim(conteudo), '$[NOT]') <> 0 and
                                        trim(cd_coluna) not in (select cd_coluna from filtros where condicao = 'NOFLOAT' and trim(micro_visao) = trim(prm_micro_visao) and trim(cd_objeto) = trim(prm_objeto) and tp_filtro = 'objeto') and
                                          trim(cd_coluna) in ( select trim(CD_COLUNA)
                                                               from   MICRO_COLUNA mc
                                                               where  trim(mc.CD_MICRO_VISAO)=trim(prm_micro_visao) and
                                                                trim(mc.cd_coluna) not in (select distinct nvl(trim(cd_coluna), 'N/A') from table(fun.vpipe_par(prm_condicoes)))
															  ) and fun.getprop(prm_objeto,'FILTRO_FLOAT') = 'N'
									
									union all
									
                                  select  'C'                   as indice,
                                          'DWU'                 as cd_usuario,
                                          trim(prm_micro_visao) as micro_visao,
                                          trim(cd_coluna)       as cd_coluna,
                                          'IGUAL'               as condicao,
                                          trim(CONTEUDO)        as conteudo,
                                          'and'                 as ligacao,
                                          'float_filter_item'   as tipo
                                   from   FLOAT_FILTER_ITEM
                                   where
                                        trim(cd_usuario) = prm_usuario and
                                        trim(screen) = trim(prm_screen) and
										instr(trim(conteudo), '$[NOT]') = 0 and
                                        trim(cd_coluna) not in (select cd_coluna from filtros where condicao = 'NOFLOAT' and trim(micro_visao) = trim(prm_micro_visao) and trim(cd_objeto) = trim(prm_objeto) and tp_filtro = 'objeto') and
                                          trim(cd_coluna) in ( select trim(CD_COLUNA)
                                                               from   MICRO_COLUNA mc
                                                               where  trim(mc.CD_MICRO_VISAO)=trim(prm_micro_visao) and
                                                                trim(mc.cd_coluna) not in (select distinct nvl(trim(cd_coluna), 'N/A') from table(fun.vpipe_par(prm_condicoes)))
															  ) and fun.getprop(prm_objeto,'FILTRO_FLOAT') = 'N'
									union all
														 select 'C'                   as indice,
                                                                'DWU'                 as cd_usuario,
                                                                trim(prm_micro_visao) as micro_visao,
                                                                trim(cd_coluna)       as cd_coluna,
                                                                cd_condicao           as condicao,
                                                                trim(CD_CONTEUDO)     as conteudo,
                                                                'and'                 as ligacao,
                                                                'condicoes'           as tipo
                                                         from   table(fun.vpipe_par(p_condicoes)) pc
                                                         where  cd_coluna <> '1' and (
                                                                    trim(cd_coluna) in (
                                                                
                                                                     select trim(CD_COLUNA)
                                                                                     from   MICRO_COLUNA
                                                                                     where  trim(CD_MICRO_VISAO)=trim(prm_micro_visao)
																					 and fun.getprop(prm_objeto,'FILTRO_DRILL') = 'N'
                                                                            union all
                                                                                     select trim(CD_COLUNA)
                                                                                     from   MICRO_VISAO_FPAR
                                                                                     where  trim(CD_MICRO_VISAO)=trim(prm_micro_visao))
                                                                    or prm_objeto like ('COBJ%')
                                                                    
                                                                   
                                                                ) and
																
																
																TRIM(CD_COLUNA)||TRIM(CD_CONTEUDO) NOT IN (
																	select nof.cd_coluna||nof.CONTEUDO FROM   FILTROS nof
																	WHERE  TRIM(nof.MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND 
																	TRIM(nof.CONDICAO) = 'NOFILTER' and 
																	trim(nof.conteudo) = trim(pc.CD_CONTEUDO) AND 
																	trim(nof.CD_OBJETO) = TRIM(PRM_OBJETO)
																)
                                                union all
                                                         select 'A'                     as indice,
                                                                'DWU'                   as cd_usuario,
                                                                rtrim(p_micro_visao)    as micro_visao,
                                                                rtrim(cd_coluna)        as cd_coluna,
                                                                rtrim(condicao)         as condicao,
                                                                rtrim(conteudo)         as conteudo,
                                                                rtrim(ligacao)          as ligacao,
                                                                'deff_line_filtro'      as tipo
                                                        from    DEFF_LINE_FILTRO
                                                        where   trim(cd_mapa)   = p_cd_mapa and
                                                                trim(nr_item)   = p_nr_item and
                                                                trim(cd_padrao) = p_cd_padrao
                                                /*union all
                                                         select 'C'                     as indice,
                                                                rtrim(cd_usuario) as cd_usuario,
                                                                rtrim(micro_visao) as micro_visao,
                                                                rtrim(cd_coluna) as cd_coluna,
                                                                rtrim(condicao)    as condicao,
                                                                rtrim(conteudo)    as conteudo,
                                                                rtrim(ligacao)     as ligacao,
                                                                'filtros_geral'    as tipo
                                                         from   FILTROS t1
                                                         where  trim(micro_visao) = trim(prm_micro_visao) and
                                                                tp_filtro = 'geral' and
                                                                (trim(cd_usuario) in (gbl.usuario, 'DWU') or trim(cd_usuario) in (select cd_usuario from gusers_itens where cd_group = t1.cd_usuario))and 
                                                                st_agrupado='N'*/
                                                union all
                                                         select 'D'                     as indice,
                                                                rtrim(cd_usuario) as cd_usuario,
                                                                rtrim(micro_visao) as micro_visao,
                                                                rtrim(cd_coluna) as cd_coluna,
                                                                rtrim(condicao)  as condicao,
                                                                rtrim(conteudo)  as conteudo,
                                                                rtrim(ligacao)  as ligacao,
                                                                'filtros_objeto' as tipo
                                                         from   FILTROS
                                                         where  trim(micro_visao) = trim(prm_micro_visao) and 
                                                                CONDICAO <> 'NOFLOAT' AND
																CONDICAO <> 'NOFILTER' AND
                                                                st_agrupado='N' and
                                                                tp_filtro = 'objeto' and
                                                                (trim(cd_objeto) = trim(prm_objeto) or (trim(cd_objeto) = trim(prm_screen) and nvl(fun.GETPROP(trim(prm_objeto),'FILTRO'), 'N/A') <> 'ISOLADO' and nvl(fun.GETPROP(trim(prm_objeto),'FILTRO'), 'N/A') <> 'COM CORTE' 
			                                                    and fun.getprop(prm_objeto,'FILTRO_TELA') <> 'S')) 
																
																and
                                                                trim(cd_usuario)  = 'DWU')
                               where   not ( trim(condicao)='IGUAL' and trim(cd_coluna) in (select trim(cd_coluna) from table(fun.vpipe_par(p_vpar))))
                               order   by tipo, cd_usuario, micro_visao, cd_coluna, condicao, conteudo;

	        ws_filtrog	crs_filtrog%rowtype;

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
							  prm_self                  in varchar2 default null ) return varchar2 as


         cursor crs_filtrog (  p_condicoes    varchar2,
                               p_micro_visao  varchar2,
                               p_cd_mapa      varchar2,
                               p_nr_item      varchar2,
                               p_cd_padrao    varchar2,
                               p_vpar         varchar2,
                               prm_usuario    varchar2 ) is

                               select distinct *
                               from (
							      select  'C'                                   as indice,
                                          'DWU'                                 as cd_usuario,
                                          trim(prm_micro_visao)                 as micro_visao,
                                          trim(cd_coluna)                       as cd_coluna,
                                          'DIFERENTE'                           as condicao,
                                          replace(trim(CONTEUDO), '$[NOT]', '') as conteudo,
                                          'and'                                 as ligacao,
                                          'float_filter_item'                   as tipo
                                   from   FLOAT_FILTER_ITEM
                                   where
                                        trim(cd_usuario) = prm_usuario and
                                        trim(screen) = trim(prm_screen) and
										instr(trim(conteudo), '$[NOT]') <> 0 and
                                        trim(cd_coluna) not in (select cd_coluna from filtros where condicao = 'NOFLOAT' and trim(micro_visao) = trim(prm_micro_visao) and trim(cd_objeto) = trim(prm_objeto) and tp_filtro = 'objeto') and
                                          trim(cd_coluna) in ( select trim(CD_COLUNA)
                                                               from   MICRO_COLUNA mc
                                                               where  trim(mc.CD_MICRO_VISAO)=trim(prm_micro_visao) and
                                                                trim(mc.cd_coluna) not in (select distinct nvl(trim(cd_coluna), 'N/A') from table(fun.vpipe_par(prm_condicoes)))
															  ) and fun.getprop(prm_objeto,'FILTRO_FLOAT') = 'N'
									
									union all
									
                                  select  'C'                   as indice,
                                          'DWU'                 as cd_usuario,
                                          trim(prm_micro_visao) as micro_visao,
                                          trim(cd_coluna)       as cd_coluna,
                                          'IGUAL'               as condicao,
                                          trim(CONTEUDO)        as conteudo,
                                          'and'                 as ligacao,
                                          'float_filter_item'   as tipo
                                   from   FLOAT_FILTER_ITEM
                                   where
                                        trim(cd_usuario) = prm_usuario and
                                        trim(screen) = trim(prm_screen) and
										instr(trim(conteudo), '$[NOT]') = 0 and
                                        trim(cd_coluna) not in (select cd_coluna from filtros where condicao = 'NOFLOAT' and trim(micro_visao) = trim(prm_micro_visao) and trim(cd_objeto) = trim(prm_objeto) and tp_filtro = 'objeto') and
                                          trim(cd_coluna) in ( select trim(CD_COLUNA)
                                                               from   MICRO_COLUNA mc
                                                               where  trim(mc.CD_MICRO_VISAO)=trim(prm_micro_visao) and
                                                                trim(mc.cd_coluna) not in (select distinct nvl(trim(cd_coluna), 'N/A') from table(fun.vpipe_par(prm_condicoes)))
															  ) and fun.getprop(prm_objeto,'FILTRO_FLOAT') = 'N'
									union all
														 select 'C'                   as indice,
                                                                'DWU'                 as cd_usuario,
                                                                trim(prm_micro_visao) as micro_visao,
                                                                trim(cd_coluna)       as cd_coluna,
                                                                cd_condicao           as condicao,
                                                                trim(CD_CONTEUDO)     as conteudo,
                                                                'and'                 as ligacao,
                                                                'condicoes'           as tipo
                                                         from   table(fun.vpipe_par(p_condicoes)) pc
                                                         where  cd_coluna <> '1' and (
                                                                    trim(cd_coluna) in (
                                                                
                                                                     select trim(CD_COLUNA)
                                                                                     from   MICRO_COLUNA
                                                                                     where  trim(CD_MICRO_VISAO)=trim(prm_micro_visao)
																					 and fun.getprop(prm_objeto,'FILTRO_DRILL') = 'N'
                                                                            union all
                                                                                     select trim(CD_COLUNA)
                                                                                     from   MICRO_VISAO_FPAR
                                                                                     where  trim(CD_MICRO_VISAO)=trim(prm_micro_visao))
                                                                    or prm_objeto like ('COBJ%')
                                                                    
                                                                   
                                                                ) and
																
																
																TRIM(CD_COLUNA)||TRIM(CD_CONTEUDO) NOT IN (
																	select nof.cd_coluna||nof.CONTEUDO FROM   FILTROS nof
																	WHERE  TRIM(nof.MICRO_VISAO) = TRIM(PRM_MICRO_VISAO) AND 
																	TRIM(nof.CONDICAO) = 'NOFILTER' and 
																	trim(nof.conteudo) = trim(pc.CD_CONTEUDO) AND 
																	trim(nof.CD_OBJETO) = TRIM(PRM_OBJETO)
																)
                                                union all
                                                         select 'A'                     as indice,
                                                                'DWU'                   as cd_usuario,
                                                                rtrim(p_micro_visao)    as micro_visao,
                                                                rtrim(cd_coluna)        as cd_coluna,
                                                                rtrim(condicao)         as condicao,
                                                                rtrim(conteudo)         as conteudo,
                                                                rtrim(ligacao)          as ligacao,
                                                                'deff_line_filtro'      as tipo
                                                        from    DEFF_LINE_FILTRO
                                                        where   trim(cd_mapa)   = p_cd_mapa and
                                                                trim(nr_item)   = p_nr_item and
                                                                trim(cd_padrao) = p_cd_padrao
                                                /*union all
                                                         select 'C'                     as indice,
                                                                rtrim(cd_usuario) as cd_usuario,
                                                                rtrim(micro_visao) as micro_visao,
                                                                rtrim(cd_coluna) as cd_coluna,
                                                                rtrim(condicao)    as condicao,
                                                                rtrim(conteudo)    as conteudo,
                                                                rtrim(ligacao)     as ligacao,
                                                                'filtros_geral'    as tipo
                                                         from   FILTROS t1
                                                         where  trim(micro_visao) = trim(prm_micro_visao) and
                                                                tp_filtro = 'geral' and
                                                                (trim(cd_usuario) in (gbl.usuario, 'DWU') or trim(cd_usuario) in (select cd_usuario from gusers_itens where cd_group = t1.cd_usuario))and 
                                                                st_agrupado='N'*/
                                                union all
                                                         select 'D'                     as indice,
                                                                rtrim(cd_usuario) as cd_usuario,
                                                                rtrim(micro_visao) as micro_visao,
                                                                rtrim(cd_coluna) as cd_coluna,
                                                                rtrim(condicao)  as condicao,
                                                                rtrim(conteudo)  as conteudo,
                                                                rtrim(ligacao)  as ligacao,
                                                                'filtros_objeto' as tipo
                                                         from   FILTROS
                                                         where  trim(micro_visao) = trim(prm_micro_visao) and 
                                                                CONDICAO <> 'NOFLOAT' AND
																CONDICAO <> 'NOFILTER' AND
                                                                st_agrupado='N' and
                                                                tp_filtro = 'objeto' and
                                                                (trim(cd_objeto) = trim(prm_objeto) or (trim(cd_objeto) = trim(prm_screen) and nvl(fun.GETPROP(trim(prm_objeto),'FILTRO'), 'N/A') <> 'ISOLADO' and nvl(fun.GETPROP(trim(prm_objeto),'FILTRO'), 'N/A') <> 'COM CORTE' 
			                                                    and fun.getprop(prm_objeto,'FILTRO_TELA') <> 'S')) 
																
																and
                                                                trim(cd_usuario)  = 'DWU')
                               where   not ( trim(condicao)='IGUAL' and trim(cd_coluna) in (select trim(cd_coluna) from table(fun.vpipe_par(p_vpar))))
                               order   by tipo, cd_usuario, micro_visao, cd_coluna, condicao, conteudo;

	        ws_filtrog	crs_filtrog%rowtype;
		 
		    cursor crs_filtro_user(prm_usuario varchar2) is 
                select			
		        trim(cd_coluna)   as cd_coluna,
                decode(trim(condicao), 'IGUAL', '=', 'DIFERENTE', '<>', 'MAIOR', '>', 'MENOR', '<', 'MAIOROUIGUAL', '>=', 'MENOROUIGUAL', '<=', 'LIKE', 'like', 'NOTLIKE', 'not like')    as condicao,
                trim(conteudo)    as conteudo,
                ligacao     as ligacao
                from   FILTROS t1
                where  trim(micro_visao) = trim(prm_micro_visao) and
                tp_filtro = 'geral' and
                (trim(cd_usuario) in (prm_usuario, 'DWU') or trim(cd_usuario) in (select cd_group from gusers_itens where cd_usuario = prm_usuario)) and 
                st_agrupado = 'N' order by cd_coluna, condicao, conteudo;
				
			ws_filtro_user crs_filtro_user%rowtype;
			
			ws_filtro_geral varchar2(2000);
			
			ws_fg_condicao   varchar2(200);
			ws_fg_coluna     varchar2(200);
			ws_fg_condicao_r varchar2(200);
			ws_fg_coluna_r   varchar2(200);
			ws_fg_conteudo_r varchar2(200);


         cursor crs_filtro_a ( p_condicoes    varchar2,
                               p_micro_visao  varchar2,
                               p_cd_mapa      varchar2,
                               p_nr_item      varchar2,
                               p_cd_padrao    varchar2,
                               p_vpar         varchar2,
                               prm_usuario    varchar2 ) is

                                select distinct *
                                from (
                                    select 'C'   as indice,
                                        rtrim(cd_usuario)       as cd_usuario,
                                        rtrim(micro_visao)      as micro_visao,
                                        rtrim(cd_coluna)        as cd_coluna,
                                        rtrim(condicao)         as condicao,
                                        rtrim(conteudo)         as conteudo,
                                        rtrim(ligacao)          as ligacao
                                        from   FILTROS t1
                                        where  trim(micro_visao) = trim(prm_micro_visao) and
                                            tp_filtro = 'geral' and
                                            (trim(cd_usuario) in (prm_usuario, 'DWU') or trim(cd_usuario) in (select cd_group from gusers_itens where cd_usuario = prm_usuario)) and 
                                            st_agrupado='S'

                                    union all
                                    
                                    select 'C'  as indice,
                                        rtrim(cd_usuario)       as cd_usuario,
                                        rtrim(micro_visao)      as micro_visao,
                                        rtrim(cd_coluna)        as cd_coluna,
                                        rtrim(condicao)         as condicao,
                                        rtrim(conteudo)         as conteudo,
                                        rtrim(ligacao)          as ligacao
                                        from   FILTROS
                                        where  trim(micro_visao) = trim(prm_micro_visao) and
                                            st_agrupado='S' and
                                            condicao <> 'NOFLOAT' and
                                            tp_filtro = 'objeto' and
                                            (
                                                trim(cd_objeto) = trim(prm_objeto) or
                                                (trim(cd_objeto) = trim(prm_screen) and fun.GETPROP(trim(prm_objeto),'FILTRO') <> 'ISOLADO')
                                            ) and
                                            rtrim(cd_usuario)  = 'DWU'
                                )
                              where not ( trim(condicao)='IGUAL' and
                                    trim(cd_coluna) in (select trim(cd_coluna) from table(fun.vpipe_par(p_vpar))))

                              order by cd_usuario, micro_visao, cd_coluna, condicao, conteudo;

	     ws_filtro_a          crs_filtro_a%rowtype;

	     cursor crs_colunas ( nm_agrupador VARCHAR2 ) is

                              select rtrim(cd_coluna) 	  as cd_coluna,
                                     decode(rtrim(st_agrupador),'MED','MEDIAN','MOD','STATS_MODE',rtrim(st_agrupador))
                                                          as st_agrupador,
                                     rtrim(cd_ligacao)    as cd_ligacao,
                                     rtrim(st_com_codigo)	as st_com_codigo,
                                     rtrim(tipo)		      as tipo,
                                     rtrim(formula)		    as formula
                              from   MICRO_COLUNA
                              where  rtrim(cd_micro_visao) = rtrim(prm_micro_visao) and
                                     rtrim(cd_coluna)      = rtrim(nm_agrupador);

         ws_colunas           crs_colunas%rowtype;

         cursor crs_eixo ( nm_var VARCHAR2 ) is

                           select	rtrim(cd_coluna)        as dt_cd_coluna,
                                    decode(rtrim(st_agrupador),'MED','MEDIAN','MOD','STATS_MODE',rtrim(st_agrupador))
                                                            as dt_st_agrupador,
                                    rtrim(cd_ligacao)       as dt_cd_ligacao,
                                    rtrim(st_com_codigo)    as dt_com_codigo,
                                    rtrim(tipo)             as tipo,
                                    rtrim(formula)          as formula
                                    from 	MICRO_COLUNA
                                    where	rtrim(cd_micro_visao) = prm_micro_visao and
                                    rtrim(cd_coluna)      = rtrim(nm_var);

         ws_eixo		crs_eixo%rowtype;

         cursor crs_tabela is
                        select nm_tabela
                        from   MICRO_VISAO
                        where  nm_micro_visao = prm_micro_visao;

         type ws_tmcolunas is table of	MICRO_COLUNA%ROWTYPE
                           index by pls_integer;

         ws_tabela      crs_tabela%rowtype;

         cursor crs_lcalc is
                        Select Cd_Objeto,
                               Cd_Micro_Visao,
                               Cd_Coluna,
                               Cd_Coluna_Show||'[LC]' as Cd_Coluna_Show,
                               Ds_Coluna_Show,
                               Ds_Formula
                        from   LINHA_CALCULADA
                        where  cd_objeto      = prm_objeto and
                               cd_micro_visao = prm_micro_visao;

         ws_lcalc       crs_lcalc%rowtype;

         cursor crs_fpar is
                       Select Cd_Coluna,
                              Cd_parametro
                       from   MICRO_VISAO_FPAR
                       where  cd_micro_visao = prm_micro_visao
                       order by cd_coluna;

         ws_fpar       crs_fpar%rowtype;

         type          generic_cursor is   ref cursor;
         crs_saida     generic_cursor;

    type               coltp_array is table of varchar2(4000) index by varchar2(4000);
    ws_col_having      coltp_array;

	ws_pvcolumns                 DBMS_SQL.VARCHAR2_TABLE;
	ws_agrupadores               DBMS_SQL.VARCHAR2_TABLE;

    ws_nm_label                  DBMS_SQL.VARCHAR2_TABLE;
    ws_nm_original               DBMS_SQL.VARCHAR2_TABLE;
    ws_tp_label                  DBMS_SQL.VARCHAR2_TABLE;
    ws_prm_query_padrao          DBMS_SQL.VARCHAR2a;


    ret_mcol                     ws_tmcolunas;

    ret_colup                    long;
    ret_lcross                   varchar2(4000);
	ws_versao_oracle             number;
    ws_calculadas                number := 0;
    ws_ct_label                  number := 0;
	ws_counter                   number := 1;
	ws_ctcolumn                  number := 1;
	ws_contador                  numeric(3);
	ws_nlabel                    varchar2(2000);
	ws_pipe                      char(1);
	ws_virgula                   char(1);
	ws_endgrp                    char(3);
	ws_bindn                     number;
	ws_bindns                     number;
	ws_lquery                    number := 1;
	ws_vcols                     number := 0;
	ws_ccoluna                   number;
	ws_linhas                    number;
	ws_ctlist                    number;
	ws_vcount                    number;
	ws_ctfix                     number;
	ws_pcursor                   integer;
	ws_xoperador                 varchar2(10);
	ws_cd_coluna_ant             varchar2(4000);
	ws_noloop                    varchar2(10);
    ws_unionall                  varchar2(6000);
	ws_condicao_ant              varchar2(6000);
	ws_ligacao_ant               varchar2(4000);
	ws_identificador             varchar2(4000);
	ws_conteudo_ant              varchar2(4000);
    ws_tipo_ant                  varchar2(4000);
	ws_indice_ant                varchar2(5);
	ws_initin                    varchar2(20);
	ws_tmp_condicao              varchar2(32000);
	ws_tmp_col                   varchar2(32000);
	ws_tcondicao                 varchar2(32000);
	ws_ligwhere                  varchar2(10);
	ws_par_function              varchar2(4000);
    ws_coluna_principal          varchar2(4000)       :=  null;

	ws_dc_inicio                 long;
	ws_dc_final                  long;
	ws_cursor                    long;
	ws_coluna                    long;
	ws_distintos                 long;
	ws_ordem                     long;
    ws_limited_query             varchar2(80);
	ws_grupo                     long;
	ws_grouping                  long;
	ws_agrupador                 long;
	ws_gorder                    long;
	ws_gord_r                    long;
	ws_aux                       long := 'OK';

	crlf                         VARCHAR2( 2 ):= CHR( 13 ) || CHR( 10 );

	ws_nulo                      long;
	ws_dcoluna                   long;
	ws_texto                     long;
	ws_textot                    long;
	ws_cm_var                    long;
	ws_nm_var                    long;
	ws_ct_var                    long;
	ws_condicoes                 long;
	ws_condicoes_self            long;
	ws_having                    long;
	ws_desc_grp                  long;
	ws_mfiltro                   long;
	ws_conteudo_comp             long;
	ws_p_micro_visao             long   := '';
	ws_p_cd_mapa                 long   := '';
	ws_p_nr_item                 long   := '';
	ws_p_cd_padrao               long   := '';
    ws_check_columns             varchar2(4000);
    ws_opttable                  varchar2(8000);
    ws_sub                       varchar2(80);
    ws_self                      varchar2(1000);
    ws_filtro_sub                varchar2(32000);
    ws_coluna_formula            varchar2(800);
    ws_coluna_dim                varchar2(80);
    ws_usuario                   varchar2(80);
    ws_ordem_user                varchar2(80);

	ws_vazio                     boolean := True;
	ws_nodata                    exception;
    ws_nouser                    exception;

  ws_zebra number;
  ws_top_n number := 0;
 

begin
 
    ws_usuario := gbl.getUsuario;

    if nvl(ws_usuario, 'NOUSER') = 'NOUSER' then
		raise ws_nouser;
	end if;

    ws_self := replace(prm_self, 'SUBQUERY_', '');   -- Alterado na procedure fcl.subquery para passar o prm_self concatenado com a palavra SUBQUERY_

    prm_cab_cross := '';

   
	select count(*) into ws_calculadas
	from   LINHA_CALCULADA
	where  cd_objeto      = prm_objeto and
	       cd_micro_visao = prm_micro_visao;

	if length(ws_self) > 0 then
	    ws_calculadas := 0;
	end if;

    ws_par_function := '';
    ws_pipe := '';

    open crs_fpar;
        loop
            fetch crs_fpar into ws_fpar;
            exit when crs_fpar%notfound;
            ws_par_function := ws_par_function||ws_pipe||ws_fpar.cd_coluna||'|'||ws_fpar.cd_parametro;
            ws_pipe         := '|';
        end loop;
    close crs_fpar;

    if  prm_rp = 'SUMARY' then
        ws_agrupadores(1) := substr(prm_condicoes||'|'||ws_self, 1 ,instr(prm_condicoes||'|'||ws_self,'|')-1);
    else
        ws_distintos      := fun.ret_list(prm_agrupador, ws_agrupadores);
    end if;

    ws_distintos := ' ';
    ws_gorder    := ' ';
    ws_gord_r    := ' ';

    ws_grouping  := '';
	ws_agrupador := prm_agrupador;
	ws_dcoluna   := prm_coluna;


    if length(ws_self) > 0 then
        ws_sub := substr(ws_self, 0, instr(ws_self, '|')-1);
    end if;

    if  prm_rp = 'CUBE' then
        ws_grupo := 'group by cube(';
	    ws_ordem := 'order by ';
    end if;

    if  prm_rp = 'ROLL' then
        ws_grupo := 'group by rollup(';
    end if;

    if  prm_rp = 'GROUP' then
        ws_grupo := 'group by (';
    end if;

    if  prm_rp = 'SUMARY' then
        ws_dcoluna := 'NO';
    end if;

    open crs_tabela;
    fetch crs_tabela into ws_tabela;
    close crs_tabela;

    ws_opttable := ws_tabela.nm_tabela;

    ws_distintos     := '';
    ws_pipe          := '';
    ws_texto         := ws_dcoluna;
    ws_textot        := ws_texto;
    ws_check_columns := '';


	loop
        if  ws_textot = '%END%' or ws_textot = 'NO'  then
            exit;
        end if;

        if  instr(ws_textot,'|') = 0 then
            ws_nm_var := ws_textot;
            ws_textot := '%END%';
        else
             ws_texto  := ws_textot;
            ws_nm_var := '##'||substr(ws_textot, 1 ,instr(ws_texto,'|')-1);
            --bug do clone aqui, ## pra não dar replace em colunas parecidas
            ws_textot := replace('##'||ws_texto, ws_nm_var||'|', '');
            ws_nm_var := replace(ws_nm_var, '##', '');
        end if;

        case substr(ws_nm_var,1,2)
            when '&[' then
                             ws_cm_var := replace(substr(ws_nm_var,1,instr(ws_nm_var,'][')-1),'&[','');
                             ws_nm_var := substr(ws_nm_var,instr(ws_nm_var,'][')+2,((length(ws_nm_var))-(instr(ws_nm_var,'][')+2)));
                             
                             if  substr(ws_cm_var,1,5)='EXEC=' then
                                 ws_cm_var := substr(ws_cm_var,6,length(substr(ws_cm_var,6,length(ws_cm_var))));
                             else
                                 ws_cm_var := ' '||fun.subvar(ws_cm_var)||' ';
                             end if;

              when '#[' then
                             ws_cm_var := replace(substr(ws_nm_var,1,instr(ws_nm_var,'][')-1),'#[','');
                             ws_nm_var := substr(ws_nm_var,instr(ws_nm_var,'][')+2,((length(ws_nm_var))-(instr(ws_nm_var,'][')+2)));
              else
                             ws_cm_var := 'NO_HINT';
        end case;

        if  ws_cm_var = 'NO_HINT' then
            open  crs_eixo(ws_nm_var);
            fetch crs_eixo into ws_eixo;
            close crs_eixo;
        else
            ws_eixo.dt_cd_coluna    := ws_nm_var;
            ws_eixo.dt_st_agrupador := 'SEM';
            ws_eixo.dt_cd_ligacao   := 'SEM';
            ws_eixo.dt_com_codigo   := 'N';
            ws_eixo.tipo            := 'C';
            ws_eixo.formula         := '';
        end if;


        if  ws_cm_var <> 'NO_HINT' then
            ws_eixo.formula := ws_cm_var;
        end if;

        if  trim(ws_eixo.dt_st_agrupador) = 'SEM' or trim(ws_eixo.dt_st_agrupador) = 'EXT' then
                if trim(ws_eixo.dt_st_agrupador) = 'EXT' then
                    ws_coluna_dim := REPLACE(replace(fun.gformula2(prm_micro_visao, ws_eixo.dt_cd_coluna, prm_screen, '', prm_objeto), 'SEM(', ''), ')', '');
                    ws_eixo.formula := ws_coluna_dim;
                else
                    ws_coluna_dim := ws_eixo.dt_cd_coluna;
                end if;
                prm_ncolumns(ws_ctcolumn) := ws_coluna_dim;
                ws_ctcolumn  := ws_ctcolumn + 1;
                if  ws_eixo.tipo = 'C' or ws_cm_var <> 'NO_HINT' then

                    if  ws_calculadas > 0 then
                        ws_ct_label                 := ws_ct_label + 1;
                        ws_nm_label(ws_ct_label)    := 'r_'||ws_coluna_dim||'_'||ws_ct_label;
                        ws_nm_original(ws_ct_label) := ws_coluna_dim;
                        ws_tp_label(ws_ct_label)    := '1';
                        ws_nlabel                   := '_'||ws_ct_label;
                    end if;

                    /*if  substr(prm_ordem,1,4) = 'DRE=' then
                        ws_nlabel := '';
                    end if;*/
                    ws_distintos  := ws_distintos||ws_eixo.formula||' as r_'||ws_coluna_dim||ws_nlabel||','||crlf;

                    ws_grupo      := ws_grupo||ws_eixo.formula||',';
                    ws_grouping   := ws_grouping||ws_eixo.formula||',';
                    if  nvl(trim(ws_gorder),'SEM') = 'SEM' then
                        ws_gorder := ' grouping('||ws_eixo.formula||'),';
                    else
                        --begin
                        --    ws_gord_r := ws_gord_r||' grouping('||ws_eixo.formula||'),'||nvl(prm_ordem, 1)||',';
                        --exception when others then
                            ws_gord_r := ws_gord_r||' grouping('||ws_eixo.formula||'),';
                        --end;
                    end if;
                    ws_ordem      := ws_ordem||ws_eixo.formula||',';

                    if  ws_coluna_principal is null then
                        ws_coluna_principal := ws_eixo.formula;
                    end if;


                else

                    if  ws_calculadas > 0 then
                        ws_ct_label                 := ws_ct_label + 1;
                        ws_nm_label(ws_ct_label)    := 'r_'||ws_coluna_dim||'_'||ws_ct_label;
                        ws_nm_original(ws_ct_label) := ws_coluna_dim;
                        ws_tp_label(ws_ct_label)    := '1';
                        ws_nlabel                   := '_'||ws_ct_label;
                    end if;

                    
					/*
					descrição junto com o código
                    if  trim(ws_eixo.dt_cd_ligacao)<>'SEM' then
                        ws_distintos  := ws_distintos||ws_eixo.dt_cd_coluna||'||'' - ''||fun.cdesc('||ws_eixo.dt_cd_coluna||','''||ws_eixo.dt_cd_ligacao||''') as ret_'||ws_eixo.dt_cd_coluna||ws_nlabel||','||crlf;
					else
					*/

					ws_distintos  := ws_distintos||ws_coluna_dim||' as r_'||ws_coluna_dim||ws_nlabel||','||crlf;
					
                    /*
					end if;
					ws_distintos  := ws_distintos||' - fun.cdesc('||ws_eixo.dt_cd_coluna||','''||ws_eixo.dt_cd_ligacao||''') as ret_nm_'||ws_eixo.dt_cd_coluna||ws_nlabel||'_desc,'||crlf;
                    */
					
                    ws_check_columns := ws_check_columns||ws_pipe||ws_coluna_dim;
                    ws_pipe          := '|';

                    ws_grupo      := ws_grupo||ws_coluna_dim||',';
                    ws_grouping   := ws_grouping||ws_coluna_dim||',';
                    if  nvl(trim(ws_gorder),'SEM') = 'SEM' then
                        ws_gorder := ' grouping('||ws_coluna_dim||'),';
                    else
                        --begin
                        --    ws_gord_r := ws_gord_r||' grouping('||ws_coluna_dim||'),'||nvl(prm_ordem, 1)||',';
                        --exception when others then
                            ws_gord_r := ws_gord_r||' grouping('||ws_coluna_dim||'),';
                        --end;
                    end if;
                    ws_ordem      := ws_ordem||ws_coluna_dim||',';

                    if  ws_coluna_principal is null then
                        ws_coluna_principal := ws_coluna_dim;
                    end if;

		         end if; 

         if  trim(ws_eixo.dt_cd_ligacao) <> 'SEM' then
             prm_ncolumns(ws_ctcolumn) := ws_eixo.dt_cd_coluna;
             ws_ctcolumn               := ws_ctcolumn + 1;

             if  ws_calculadas > 0 then
                 ws_ct_label                 := ws_ct_label + 1;
                 --   ws_nm_label(ws_ct_label)    := core.cdesc_sql(ws_eixo.dt_cd_ligacao,  ws_opttable||'.'||ws_eixo.dt_cd_coluna) ;    -- teste alternativa a FUN.CDESC
                 ws_nm_label(ws_ct_label)    := 'fun.cdesc('||' r_'||ws_eixo.dt_cd_coluna||ws_nlabel ||','''||ws_eixo.dt_cd_ligacao||''')';
                 ws_nm_original(ws_ct_label) := ws_eixo.dt_cd_coluna;
                 ws_tp_label(ws_ct_label)    := '2';
                 ws_nlabel                   := '_'||ws_ct_label;
             end if;

             /*if  substr(prm_ordem,1,4) = 'DRE=' then
                 ws_nlabel := '';
             end if;*/

                if  ws_cm_var = 'NO_HINT' then
                    --    ws_distintos  := ws_distintos||' '||core.cdesc_sql(ws_eixo.dt_cd_ligacao,  ws_opttable||'.'||ws_eixo.dt_cd_coluna)|| ' as r_nm_'||ws_eixo.dt_cd_coluna||ws_nlabel||'_d,'||crlf;  -- teste alternativa a FUN.CDESC
                    ws_distintos  := ws_distintos||'fun.cdesc('||ws_eixo.dt_cd_coluna||','''||ws_eixo.dt_cd_ligacao||''') as r_nm_'||ws_eixo.dt_cd_coluna||ws_nlabel||'_d,'||crlf;
                else
                    ws_distintos  := ws_distintos||'('''||ws_cm_var||''') as r_nm_'||ws_eixo.dt_cd_coluna||ws_nlabel||'_d,'||crlf;
                end if;
            end if;
        end if;
    end loop;

    ws_bindn  := 1;
	ws_bindns  := 1;


    --if length(prm_self) > 0 then
	--    ws_texto     := prm_self||'|'||prm_condicoes;
	--else
	    ws_texto     := prm_condicoes;
	--end if;

    if  prm_rp = 'SUMARY' then
        ws_agrupador := substr(ws_texto, 1 ,instr(ws_texto,'|')-1);
        ws_texto := replace(ws_texto, ws_agrupador||'|', '');
    end if;


    /*if  substr(prm_ordem,1,4) = 'DRE=' then
        ws_p_micro_visao := prm_micro_visao;
        select trim(nvl(cd_conteudo,'')) into ws_p_cd_mapa   from table(fun.vpipe_par(replace(prm_ordem,'DRE=',''))) where cd_coluna='cd_mapa';
        select trim(nvl(cd_conteudo,'')) into ws_p_nr_item   from table(fun.vpipe_par(replace(prm_ordem,'DRE=',''))) where cd_coluna='nr_item';
        select trim(nvl(cd_conteudo,'')) into ws_p_cd_padrao from table(fun.vpipe_par(replace(prm_ordem,'DRE=',''))) where cd_coluna='cd_padrao';
    end if;*/

    

    if  length(trim(prm_self)) > 9 then 
        ws_filtro_sub := ws_texto||'|'||ws_self;
    else
        ws_filtro_sub := ws_texto;
    end if;

    if  length(prm_self) > 0 then
        ws_cd_coluna_ant  := 'NOCHANGE_ID';
	    ws_ligacao_ant    := 'NOCHANGE_ID';
	    ws_condicao_ant   := 'NOCHANGE_ID';
	    ws_indice_ant     := 0;
	    ws_initin         := 'NOINIT';
        ws_tmp_condicao   := '';
        ws_noloop         := 'NOLOOP';
        ws_tipo_ant       := 'NOCHANGE_ID';
        ws_condicoes_self := ws_condicoes_self||'where ( ( ';

        ws_texto := replace(ws_texto, '||', '|');

        open crs_filtrog( ws_filtro_sub,
                             ws_p_micro_visao,
                             ws_p_cd_mapa,
                             ws_p_nr_item,
                             ws_p_cd_padrao,
                             ws_par_function, 
                             ws_usuario );
        loop
            fetch crs_filtrog into ws_filtrog;
                  exit when crs_filtrog%notfound;

                  if  fun.vcalc(ws_filtrog.cd_coluna, prm_micro_visao) then
                      ws_filtrog.cd_coluna := fun.xcalc(ws_filtrog.cd_coluna, ws_filtrog.micro_visao, prm_screen);
                  end if;

                  ws_noloop := 'LOOP';

                 if  prm_objeto = '%NO_BIND%' then
                     ws_conteudo_comp := chr(39)||ws_conteudo_ant||chr(39);
                 else
                     ws_conteudo_comp := ' :b'||trim(to_char(ws_bindn,'0000'));
                 end if;

                

                 if  ws_condicao_ant <> 'NOCHANGE_ID' then
                     if  (ws_filtrog.cd_coluna = ws_cd_coluna_ant and ws_filtrog.tipo=ws_tipo_ant) and ws_condicao_ant in ('IGUAL','DIFERENTE') then
                         if  ws_initin <> 'BEGIN' then
                             ws_condicoes_self := ws_condicoes_self||ws_tmp_condicao;
                             ws_tmp_condicao := '';
                         end if;
                         ws_initin := 'BEGIN';
                         ws_tmp_condicao := ws_tmp_condicao||ws_conteudo_comp||',';
                         ws_bindns := ws_bindns + 1;
                     else
                         if  ws_initin = 'BEGIN' then
                             ws_tmp_condicao := ws_tmp_condicao||ws_conteudo_comp||',';
                             ws_tmp_condicao := substr(ws_tmp_condicao,1,length(ws_tmp_condicao)-1);
                             ws_condicoes_self := ws_condicoes_self||ws_cd_coluna_ant||fcl.fpdata(ws_condicao_ant,'IGUAL',' IN ',' NOT IN ')||'('||ws_tmp_condicao||') '||ws_ligacao_ant||crlf;
                             ws_tmp_condicao := '';
                             ws_initin := 'NOINIT';
                         else
                             ws_condicoes_self := ws_condicoes_self||ws_tmp_condicao;
                             ws_tmp_condicao := '';
                             if  ws_filtrog.tipo <> ws_tipo_ant then
                                 ws_tmp_condicao := ws_tmp_condicao||ws_cd_coluna_ant||ws_tcondicao||ws_conteudo_comp||' ) '||ws_ligacao_ant||' ( '||crlf;
                             else
                                 ws_tmp_condicao := ws_tmp_condicao||ws_cd_coluna_ant||ws_tcondicao||ws_conteudo_comp||' '||ws_ligacao_ant||' '||crlf;
                             end if;
                         end if;
                         ws_bindns := ws_bindns + 1;
                     end if;
                 end if;

                 ws_cd_coluna_ant := ws_filtrog.cd_coluna;
                 ws_condicao_ant  := ws_filtrog.condicao;
                 ws_indice_ant    := ws_filtrog.indice;
                 ws_ligacao_ant   := ws_filtrog.ligacao;
                 ws_conteudo_ant  := ws_filtrog.conteudo;
                 ws_tipo_ant      := ws_filtrog.tipo;

                 case ws_condicao_ant
                                     when 'IGUAL'        then ws_tcondicao := '=';
                                     when 'DIFERENTE'    then ws_tcondicao := '<>';
                                     when 'MAIOR'        then ws_tcondicao := '>';
                                     when 'MENOR'        then ws_tcondicao := '<';
                                     when 'MAIOROUIGUAL' then ws_tcondicao := '>=';
                                     when 'MENOROUIGUAL' then ws_tcondicao := '<=';
                                     when 'LIKE'         then ws_tcondicao := ' like ';
                                     when 'NOTLIKE'      then ws_tcondicao := ' not like ';
                                     else                     ws_tcondicao := '***';
                end case;
	      end loop;
          close crs_filtrog;

		  if  prm_objeto = '%NO_BIND%' then
		      ws_conteudo_comp := chr(39)||ws_conteudo_ant||chr(39);
		  else
			  ws_conteudo_comp := ' :b'||trim(to_char(ws_bindns,'0000'));
		  end if;

		  if ws_noloop <> 'NOLOOP' then
		    if  ws_initin = 'BEGIN' then
					ws_tmp_condicao := ws_tmp_condicao||ws_conteudo_comp||',';
					ws_tmp_condicao := substr(ws_tmp_condicao,1,length(ws_tmp_condicao)-1);
					ws_condicoes_self := ws_condicoes_self||ws_cd_coluna_ant||fcl.fpdata(ws_condicao_ant,'IGUAL',' IN ',' NOT IN ')||'('||ws_tmp_condicao||')'||crlf;
					ws_bindns := ws_bindns + 1;
				else
					ws_tmp_condicao := ws_tmp_condicao||ws_cd_coluna_ant||ws_tcondicao||ws_conteudo_comp||crlf;
					ws_condicoes_self := ws_condicoes_self||ws_tmp_condicao;
					ws_bindns := ws_bindns + 1;
				end if;
			end if;

		  if  substr(ws_condicoes_self,length(ws_condicoes_self)-3, 3) ='( (' then
              ws_condicoes_self := substr(ws_condicoes,1,length(ws_condicoes_self)-10)||crlf;
          else
              ws_condicoes_self := ws_condicoes_self||' ) ) ';
          end if;

    end if;

    ws_cd_coluna_ant  := 'NOCHANGE_ID';
	ws_ligacao_ant    := 'NOCHANGE_ID';
	ws_condicao_ant   := 'NOCHANGE_ID';
    ws_tipo_ant       := 'NOCHANGE_ID';
	ws_indice_ant     := 0;
	ws_initin         := 'NOINIT';
    ws_tmp_condicao   := '';
    ws_noloop         := 'NOLOOP';
    ws_condicoes      := ws_condicoes||'where ( ( ';


    open crs_filtrog( ws_texto||'|'||ws_self,
                      ws_p_micro_visao,
                      ws_p_cd_mapa,
                      ws_p_nr_item,
                      ws_p_cd_padrao,
                      ws_par_function, ws_usuario );
    loop
        fetch crs_filtrog into ws_filtrog;
              exit when crs_filtrog%notfound;

              if  fun.vcalc(ws_filtrog.cd_coluna, prm_micro_visao) then
                  ws_filtrog.cd_coluna := fun.xcalc(ws_filtrog.cd_coluna, ws_filtrog.micro_visao, prm_screen);
              end if;

              ws_noloop := 'LOOP';

              if  prm_objeto = '%NO_BIND%' then
                  ws_conteudo_comp := chr(39)||ws_conteudo_ant||chr(39);
              else
                  ws_conteudo_comp := ' :b'||trim(to_char(ws_bindn,'0000'));
              end if;

              if  ws_condicao_ant <> 'NOCHANGE_ID' then
                  if  (ws_filtrog.cd_coluna=ws_cd_coluna_ant and ws_filtrog.condicao=ws_condicao_ant) and ws_condicao_ant in ('IGUAL','DIFERENTE') then
                      if  ws_initin <> 'BEGIN' then
                          ws_condicoes := ws_condicoes||ws_tmp_condicao;
                          ws_tmp_condicao := '';
                      end if;
                      ws_initin := 'BEGIN';
                      ws_tmp_condicao := ws_tmp_condicao||ws_conteudo_comp||',';
                      ws_bindn := ws_bindn + 1;
                  else
                      if  ws_initin = 'BEGIN' then
                          ws_tmp_condicao := ws_tmp_condicao||ws_conteudo_comp||',';
                          ws_tmp_condicao := substr(ws_tmp_condicao,1,length(ws_tmp_condicao)-1);
                          ws_condicoes := ws_condicoes||ws_cd_coluna_ant||fcl.fpdata(ws_condicao_ant,'IGUAL',' IN ',' NOT IN ')||'('||ws_tmp_condicao||') '||ws_ligacao_ant||crlf;
                          ws_tmp_condicao := '';
                          ws_initin := 'NOINIT';
                      else
                          ws_condicoes := ws_condicoes||ws_tmp_condicao;
                          ws_tmp_condicao := '';
                          if  ws_filtrog.tipo <> ws_tipo_ant then
                              ws_tmp_condicao := ws_tmp_condicao||ws_cd_coluna_ant||ws_tcondicao||ws_conteudo_comp||' ) and ( '||crlf;
                          else
                              ws_tmp_condicao := ws_tmp_condicao||ws_cd_coluna_ant||ws_tcondicao||ws_conteudo_comp||' '||ws_ligacao_ant||' '||crlf;
                          end if;
                      end if;
                      ws_bindn := ws_bindn + 1;
                  end if;
              end if;

              ws_check_columns := ws_check_columns||ws_pipe||ws_filtrog.cd_coluna;
              ws_cd_coluna_ant := ws_filtrog.cd_coluna;
              ws_condicao_ant  := ws_filtrog.condicao;
              ws_indice_ant    := ws_filtrog.indice;
              ws_ligacao_ant   := ws_filtrog.ligacao;
              ws_conteudo_ant  := ws_filtrog.conteudo;
              ws_tipo_ant      := ws_filtrog.tipo;

              case ws_condicao_ant
                                  when 'IGUAL'        then ws_tcondicao := '=';
                                  when 'DIFERENTE'    then ws_tcondicao := '<>';
                                  when 'MAIOR'        then ws_tcondicao := '>';
                                  when 'MENOR'        then ws_tcondicao := '<';
                                  when 'MAIOROUIGUAL' then ws_tcondicao := '>=';
                                  when 'MENOROUIGUAL' then ws_tcondicao := '<=';
                                  when 'LIKE'         then ws_tcondicao := ' like ';
                                  when 'NOTLIKE'      then ws_tcondicao := ' not like ';
                                  else                     ws_tcondicao := '***';
              end case;
    end loop;

    close crs_filtrog;



    if  prm_objeto = '%NO_BIND%' then
        ws_conteudo_comp := chr(39)||ws_conteudo_ant||chr(39);
    else
        ws_conteudo_comp := ' :b'||trim(to_char(ws_bindn,'0000'));
    end if;

    if  ws_noloop <> 'NOLOOP' then
        if  ws_initin = 'BEGIN' then
            ws_tmp_condicao := ws_tmp_condicao||ws_conteudo_comp||',';
            ws_tmp_condicao := substr(ws_tmp_condicao,1,length(ws_tmp_condicao)-1);
            ws_condicoes := ws_condicoes||ws_cd_coluna_ant||fcl.fpdata(ws_condicao_ant,'IGUAL',' IN ',' NOT IN ')||'('||ws_tmp_condicao||')'||crlf;
            ws_bindn := ws_bindn + 1;
        else
            ws_tmp_condicao := ws_tmp_condicao||ws_cd_coluna_ant||ws_tcondicao||ws_conteudo_comp||crlf;   
            ws_condicoes := ws_condicoes||ws_tmp_condicao;
            ws_bindn := ws_bindn + 1;
        end if;
    end if;

    if  substr(ws_condicoes,length(ws_condicoes)-3, 3) ='( (' then
        ws_condicoes := substr(ws_condicoes,1,length(ws_condicoes)-10)||crlf;
    else
        ws_condicoes := ws_condicoes||' ) ) ';
    end if;


    ws_par_function := '';
    ws_pipe         := '';

    open crs_fpar;
    loop
        fetch crs_fpar into ws_fpar;
              exit when crs_fpar%notfound;

              ws_par_function := ws_par_function||ws_pipe||ws_fpar.cd_parametro||'=> :b'||trim(to_char(ws_bindn,'0000'));
              ws_bindn        := ws_bindn + 1;
              ws_pipe         := ',';

    end loop;
    close crs_fpar;


    ws_grouping := substr(ws_grouping,1,length(ws_grouping)-1);
	    
		ws_fg_condicao := 'N/A';
		ws_fg_coluna   := 'N/A';
	
		open crs_filtro_user(ws_usuario);
			loop
				fetch crs_filtro_user into ws_filtro_user;
				exit when crs_filtro_user%notfound;

                ws_coluna_formula := trim(fun.gformula2(prm_micro_visao, ws_filtro_user.cd_coluna, prm_screen, '', ''));
				
				if (ws_fg_condicao_r = ws_filtro_user.condicao) and (ws_fg_coluna_r = ws_coluna_formula) and (ws_fg_conteudo_r = ws_filtro_user.conteudo) then
				    ws_filtro_geral := '';
				else
				
					if (ws_fg_condicao <> ws_filtro_user.condicao) or (ws_fg_coluna <> ws_coluna_formula) then
						
						
						if ws_fg_condicao = '=' then
							ws_filtro_geral := ws_filtro_geral||') '||ws_filtro_user.ligacao;
						end if;
						
						ws_fg_condicao  := trim(ws_filtro_user.condicao);
						ws_fg_coluna    := ws_coluna_formula;


						if ws_fg_condicao = '=' then
							ws_filtro_geral := ws_filtro_geral||' '||ws_coluna_formula||' in (';
						end if;
						
					end if;
					
					if ws_filtro_user.condicao = '=' then
						ws_filtro_geral := ws_filtro_geral||''''||ws_filtro_user.conteudo||''',';
					else 
						ws_filtro_geral := ws_filtro_geral||' '||ws_coluna_formula||' '||ws_filtro_user.condicao||' '''||ws_filtro_user.conteudo||''' '||ws_filtro_user.ligacao;
					end if;

				end if;
				
				ws_fg_condicao_r := ws_filtro_user.condicao;
				ws_fg_coluna_r   := ws_coluna_formula;
				ws_filtro_geral  := replace(ws_filtro_geral, ',)', ')');
				
			end loop;
		close CRS_FILTRO_user;
		
		if ws_fg_condicao = '=' then
			ws_filtro_geral := ws_filtro_geral||')';
		end if;

		if ws_fg_condicao <> '=' then
		    ws_filtro_geral := substr(ws_filtro_geral, 0, length(ws_filtro_geral)-4);
		else
		    ws_filtro_geral := replace(ws_filtro_geral, ',)', ')');
		end if;

		-- Usado quando não tem Pivot
        if  nvl(prm_colup,'%*') = '%*' then
			ws_vcount := 0;

			loop
				ws_vcount := ws_vcount + 1;

				if  ws_vcount > ws_agrupadores.COUNT then
					exit;
				end if;

			    if  ws_agrupadores(ws_vcount) <> 'PERC_FUNCTION' then
				   open crs_colunas(ws_agrupadores(ws_vcount));
				   fetch crs_colunas into ws_colunas;
				   close crs_colunas;

				   ws_lquery := ws_lquery + 1;
				   ws_tmp_col := ws_colunas.cd_coluna;
				   if  ws_colunas.tipo='C' then
					   ws_tmp_col := fun.gformula2(prm_micro_visao, ws_colunas.cd_coluna, prm_screen, '', prm_objeto);
				   end if;

				   if  ws_calculadas > 0 then
					   ws_ct_label                 := ws_ct_label + 1;
					   ws_nm_label(ws_ct_label)    := 'r_'||ws_colunas.cd_coluna||'_'||ws_ct_label;
					   ws_nm_original(ws_ct_label) := ws_colunas.cd_coluna;
					   ws_tp_label(ws_ct_label)    := '3';
                       ws_nlabel                   := '_'||ws_ct_label;
				   end if;

				   /*if  substr(prm_ordem,1,4) = 'DRE=' then
					   ws_nlabel := '';
				   end if;*/

				   if  rtrim(ws_colunas.st_agrupador) in ('PSM','PCT','CNT') then
					   if  rtrim(ws_colunas.st_agrupador)='PSM' then
						   ws_col_having(ws_colunas.cd_coluna)     := '(RATIO_TO_REPORT(SUM  ('||ws_tmp_col||')) OVER (PARTITION BY grouping_id('||ws_grouping||'))*100) ';
						   prm_query_padrao(ws_lquery)             := '(RATIO_TO_REPORT(SUM  ('||ws_tmp_col||')) OVER (PARTITION BY grouping_id('||ws_grouping||'))*100) as r_'||ws_colunas.cd_coluna||ws_nlabel||','||crlf;
					   else
						   if  rtrim(ws_colunas.st_agrupador)='CNT' then
							   ws_col_having(ws_colunas.cd_coluna) :=  'COUNT(DISTINCT '||ws_tmp_col||') ';
							   prm_query_padrao(ws_lquery)         := 'COUNT(DISTINCT '||ws_tmp_col||') as r_'||ws_colunas.cd_coluna||ws_nlabel||','||crlf;
						   else
							   ws_col_having(ws_colunas.cd_coluna) := '(RATIO_TO_REPORT(COUNT(DISTINCT '||ws_tmp_col||')) OVER (PARTITION BY grouping_id('||ws_grouping||'))*100) ';
							   prm_query_padrao(ws_lquery)         := '(RATIO_TO_REPORT(COUNT(DISTINCT '||ws_tmp_col||')) OVER (PARTITION BY grouping_id('||ws_grouping||'))*100) as r_'||ws_colunas.cd_coluna||ws_nlabel||','||crlf;
						   end if;
					   end if;
				   elsif TRIM(WS_COLUNAS.ST_AGRUPADOR) = 'IMG' THEN
					   WS_COL_HAVING(WS_COLUNAS.CD_COLUNA)     := 'MAX('||WS_TMP_COL||') ';
					   PRM_QUERY_PADRAO(WS_LQUERY)         := 'MAX('||WS_TMP_COL||') as r_'||WS_COLUNAS.CD_COLUNA||WS_NLABEL||','||CRLF;
				   else
					   ws_col_having(ws_colunas.cd_coluna)         := fcl.fpdata(rtrim(ws_colunas.st_agrupador),'EXT','',rtrim(ws_colunas.st_agrupador))||'('||ws_tmp_col||') ';
					   prm_query_padrao(ws_lquery)                 := fcl.fpdata(rtrim(ws_colunas.st_agrupador),'EXT','',rtrim(ws_colunas.st_agrupador))||'('||ws_tmp_col||') as r_'||ws_colunas.cd_coluna||ws_nlabel||','||crlf;
				   end if;

				   prm_ncolumns(ws_ctcolumn) := ws_colunas.cd_coluna;
				   ws_ctcolumn := ws_ctcolumn + 1;
			   end if;
			  end loop;

			if  prm_rp = 'PIZZA' then
				ws_lquery   := ws_lquery + 1;
				prm_query_padrao(ws_lquery) := 'trunc((RATIO_TO_REPORT(SUM('||ws_tmp_col||')) OVER (partition by grouping_id('||prm_coluna||')))*100) as perc ';
				prm_ncolumns(ws_ctcolumn) := 'PERC';
				ws_ctcolumn := ws_ctcolumn + 1;
			end if;

		   if  nvl(trim(ws_grupo),'%NO_UNDER_GRP%') <> '%NO_UNDER_GRP%' then

				ws_lquery   := ws_lquery + 1;
				prm_query_padrao(ws_lquery) := 'grouping_id('||replace(replace(replace(substr(ws_grupo,1,length(ws_grupo)-1),'group by cube(',''),'group by rollup(',''),'group by (','')||')'||' as UP_GRP_ID';
				prm_ncolumns(ws_ctcolumn)   := 'UP_GRP_MODEL';
				ws_ctcolumn := ws_ctcolumn + 1;
				if trim(ws_coluna_principal) is not null then
					prm_query_padrao(ws_lquery) := prm_query_padrao(ws_lquery)||', grouping_id('||ws_coluna_principal||') as UP_PRINCIPAL';
					prm_ncolumns(ws_ctcolumn)   := 'UP_PRINCIPAL';
					ws_ctcolumn := ws_ctcolumn + 1;
				end if;
		   end if;

		else
			ws_bindn  := 0;
			ws_texto  := prm_colup;
			ws_textot := ' ';

			loop
				ws_bindn  := ws_bindn + 1;
				if  instr(ws_texto,'|') > 0 then
					ws_nm_var            := substr(ws_texto, 1 ,instr(ws_texto,'|')-1);
					if  fun.VCALC(ws_nm_var,prm_micro_visao) then
						ws_nm_var :=  fun.xcalc(ws_nm_var,	prm_micro_visao, prm_screen );
					end if;
					prm_pvpull(ws_bindn) := ws_nm_var;
                    commit;
					ws_texto             := replace (ws_texto, ws_nm_var||'|', '');
					ws_textot            := ws_textot||ws_nm_var||',';
				else

					if  fun.VCALC(ws_texto,prm_micro_visao) then
						ws_texto :=  fun.xcalc(ws_texto,	prm_micro_visao, prm_screen );
					end if;
					prm_pvpull(ws_bindn) := ws_texto;
                    commit;
					ws_textot            := ws_textot||ws_texto||',';
					exit;
				end if;
			end loop;

			ws_textot := substr(ws_textot,1,length(ws_textot)-1);

			if  ws_par_function <> '' then
			    ws_cursor := 'select distinct '||ws_textot||' from table('||ws_opttable||'('||ws_par_function||')) '||ws_condicoes||' order by 1';
		    else

				--if  length(prm_self) > 0 then
                if  prm_self not like 'SUBQUERY_%' then    -- Alterado para ignorar quando for SUBQUERY_  14/04/2022
                    begin
                        select listagg(regra||' and ') within group (order by regra) into ws_condicoes_self from (
                                select cd_coluna||' in ('||listagg(chr(39)||fun.subpar(conteudo, prm_screen)||chr(39), ', ') within group (order by cd_coluna)||')' as regra 
                        from (
                                select  
                                trim(cd_coluna) as cd_coluna,
                                'DIFERENTE'     as condicao,
                                replace(trim(CONTEUDO), '$[NOT]', '') as conteudo
                                from   FLOAT_FILTER_ITEM
                                where
                                trim(cd_usuario) = ws_usuario and
                                trim(screen) = trim(prm_screen) and
                                instr(trim(conteudo), '$[NOT]') <> 0 and
                                trim(cd_coluna) not in (select cd_coluna from filtros where condicao = 'NOFLOAT' and trim(micro_visao) = trim(prm_micro_visao) and trim(cd_objeto) = trim(prm_objeto) and tp_filtro = 'objeto') and
                                trim(cd_coluna) in ( select trim(CD_COLUNA)
                                                    from   MICRO_COLUNA mc
                                                    where  trim(mc.CD_MICRO_VISAO)=trim(prm_micro_visao) and
                                                        trim(mc.cd_coluna) not in (select distinct nvl(trim(cd_coluna), 'N/A') from table(fun.vpipe_par('')))
                                                    ) and fun.getprop(prm_objeto,'FILTRO_FLOAT') = 'N' AND
                                                    cd_coluna = upper(trim(ws_textot))

                                union all
                        
                                select  
                                    trim(cd_coluna)       as cd_coluna,
                                    'IGUAL'               as condicao,
                                    trim(CONTEUDO)        as conteudo
                                    
                                from   FLOAT_FILTER_ITEM
                                where
                                    trim(cd_usuario) = ws_usuario and
                                    trim(screen) = trim(prm_screen) and
                                    instr(trim(conteudo), '$[NOT]') = 0 and
                                        trim(cd_coluna) not in (select cd_coluna from filtros where condicao = 'NOFLOAT' and trim(micro_visao) = trim(prm_micro_visao) and trim(cd_objeto) = trim(prm_objeto) and tp_filtro = 'objeto') and
                                        trim(cd_coluna) in ( select trim(CD_COLUNA)
                                                        from   MICRO_COLUNA mc
                                                        where  trim(mc.CD_MICRO_VISAO)=trim(prm_micro_visao) and
                                                            trim(mc.cd_coluna) not in (select distinct nvl(trim(cd_coluna), 'N/A') from table(fun.vpipe_par('')))
                                                ) and fun.getprop(prm_objeto,'FILTRO_FLOAT') = 'N' AND
                                                cd_coluna = upper(trim(ws_textot))
                
                                union all
                                    select 
                                            rtrim(cd_coluna) as cd_coluna,
                                            rtrim(condicao)  as condicao,
                                            rtrim(conteudo)  as conteudO
                                        
                                    from   FILTROS
                                    where  trim(micro_visao) = trim(prm_micro_visao) and 
                                            CONDICAO <> 'NOFLOAT' AND
                                            CONDICAO <> 'NOFILTER' AND
                                            st_agrupado='N' and
                                            tp_filtro = 'objeto' and
                                            (trim(cd_objeto) = trim(prm_objeto) or (trim(cd_objeto) = trim(prm_screen) and nvl(fun.GETPROP(trim(prm_objeto),'FILTRO'), 'N/A') <> 'ISOLADO' and nvl(fun.GETPROP(trim(prm_objeto),'FILTRO'), 'N/A') <> 'COM CORTE' 
                                            and fun.getprop(prm_objeto,'FILTRO_TELA') <> 'S')) 
                                            
                                            and
                                            trim(cd_usuario)  in ('DWU', ws_usuario) AND
                                            cd_coluna = upper(trim(ws_textot))
                                ) 
                                group by cd_coluna);
                    exception when others then
                        insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SUBQUERY', user, 'ERRO');
                        commit;
                        ws_condicoes_self := '';
                    end;

                    ws_condicoes_self := substr(trim(ws_condicoes_self), 0, length(trim(ws_condicoes_self))-3);

                    if length(trim(ws_condicoes_self)) > 1 then
                        ws_cursor := 'select distinct '||ws_textot||' frOm '||ws_opttable||' where '||ws_condicoes_self||' order by 1';
                    else
                        ws_cursor := 'select distinct '||ws_textot||' frOm '||ws_opttable||' order by 1';
                    end if;
                else
					if length(ws_filtro_geral) > 2 then
						if length(trim(ws_condicoes)) > 2 then
							ws_cursor := 'select distinct '||ws_textot||' From '||ws_opttable||' '||ws_condicoes||' and '||ws_filtro_geral||' order by 1';
						else
							ws_cursor := 'select distinct '||ws_textot||' fRom '||ws_opttable||' where '||ws_filtro_geral||' order by 1';
						end if;
					else
						ws_cursor := 'select distinct '||ws_textot||' froM '||ws_opttable||' '||ws_condicoes||' order by 1';
					end if;
				end if;
		end if;

        ws_pcursor := dbms_sql.open_cursor;
        prm_query_pivot := ws_cursor;

        dbms_sql.parse(ws_pcursor, ws_cursor, dbms_sql.native);

        ws_bindn := 0;

        loop
            ws_bindn := ws_bindn + 1;
            if  ws_bindn > prm_pvpull.COUNT then
                exit;
            end if;

            dbms_sql.define_column(ws_pcursor, ws_bindn, ret_colup, 40);
            
            commit;
        end loop;

		begin 
		ws_nulo := core.bind_direct(prm_condicoes||'|'||ws_self, ws_pcursor, '', prm_objeto, prm_micro_visao, prm_screen);
		exception when others then
            insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - MONTA_QUERY', ws_usuario, 'ERRO');
            commit;
		end;

        ws_linhas := dbms_sql.execute(ws_pcursor);

        ws_counter := 0;
        ws_ccoluna := 0;
        ws_ctlist  := 0;

        loop
            ws_linhas := dbms_sql.fetch_rows(ws_pcursor);
            if  ws_linhas = 1 then
                ws_vazio := False;
            else
                if  ws_vazio = True then
                    dbms_sql.close_cursor(ws_pcursor);
                    raise ws_nodata;
                end if;
                exit;
            end if;
            
            
            ws_mfiltro   := '';
            ws_bindn     := 0;
            ws_dc_inicio := ' ';
            ws_dc_final  := ' ';
            ws_desc_grp  := '';
            ws_pipe	     := '';
            
            loop
                ws_bindn := ws_bindn + 1;
                if  ws_bindn > prm_pvpull.COUNT then
                    exit;
                end if;

                ws_mfiltro   := ws_mfiltro||ws_pipe;
                dbms_sql.column_value(ws_pcursor, ws_bindn, ret_colup);
                ws_dc_inicio := ws_dc_inicio||'decode('||prm_pvpull(ws_bindn)||','''||ret_colup||''',';
                ws_dc_final  := ws_dc_final||',null)';
                ws_desc_grp  := ws_desc_grp||'_'||ret_colup;
                ws_ctlist    := ws_ctlist + 1;
                ws_mfiltro   := ws_mfiltro||prm_pvpull(ws_bindn)||'|'||ret_colup;
                ws_pipe      := '|';
            end loop;
            
            ws_vcount   := 0;
            loop
                ws_vcount := ws_vcount + 1;

                if  ws_vcount > ws_agrupadores.COUNT then
                    exit;
                end if;

                if  ws_agrupadores(ws_vcount) <> 'PERC_FUNCTION'  then

                    open crs_colunas(ws_agrupadores(ws_vcount));
                    fetch crs_colunas into ws_colunas;
                    close crs_colunas;

                    ws_lquery := ws_lquery + 1;
                    ws_tmp_col := ws_colunas.cd_coluna;
                    if  ws_colunas.tipo='C' then
                        if  rtrim(ws_colunas.st_agrupador) <> 'EXT' then
                            ws_tmp_col := ws_dc_inicio||fun.gformula2(prm_micro_visao, ws_colunas.cd_coluna, prm_screen, '', prm_objeto)||ws_dc_final;
                        else

                            ws_tmp_col := fun.gformula2(prm_micro_visao, ws_colunas.cd_coluna, prm_screen, '', prm_objeto, ws_dc_inicio, ws_dc_final);
                        end if;
                    else
                        ws_tmp_col := ws_dc_inicio||ws_tmp_col||ws_dc_final;
                    end if;
                    
                end if;

                if  ws_calculadas > 0 then
                    ws_ct_label                 := ws_ct_label + 1;
                    ws_nm_label(ws_ct_label)    := 'r_'||ws_colunas.cd_coluna||'_'||ws_ct_label;
                    ws_nm_original(ws_ct_label) := ws_colunas.cd_coluna;
                    ws_tp_label(ws_ct_label)    := '3';
                    ws_nlabel                   := '_'||ws_ct_label;
                end if; 

                /*if  substr(prm_ordem,1,4) = 'DRE=' then
                    ws_nlabel := '';
                end if;*/

                if  rtrim(ws_colunas.st_agrupador) in ('PSM','PCT','CNT') then  -- Adicionado o ws_lquery para resolver erro de coluna ambigua - 22/04/2022 
                    if  rtrim(ws_colunas.st_agrupador)='PSM' then
                        prm_query_padrao(ws_lquery)     := 'trunc((RATIO_TO_REPORT(SUM('||ws_tmp_col||')) OVER ()*100)) as r_'||ws_colunas.cd_coluna||ws_nlabel||ws_lquery||','||crlf;
                    else
                        if  rtrim(ws_colunas.st_agrupador)='CNT' then
                            prm_query_padrao(ws_lquery) := '(COUNT(DISTINCT '||ws_tmp_col||')) as r_'||ws_colunas.cd_coluna||ws_nlabel||ws_lquery||','||crlf;  
                         else
                            prm_query_padrao(ws_lquery) := 'trunc((RATIO_TO_REPORT(COUNT(DISTINCT '||ws_tmp_col||')) OVER ()*100)) as r_'||ws_colunas.cd_coluna||ws_nlabel||ws_lquery||','||crlf;
                        end if;
                    end if;
                else
                    prm_query_padrao(ws_lquery)         := fcl.fpdata(rtrim(ws_colunas.st_agrupador),'EXT','',trim(ws_colunas.st_agrupador))||'('||ws_tmp_col||') aS r_'||ws_colunas.cd_coluna||ws_nlabel||ws_lquery||','||crlf;
                end if;

              prm_ncolumns(ws_ctcolumn) := ws_colunas.cd_coluna;
              ws_ctcolumn               := ws_ctcolumn + 1;
              prm_mfiltro(ws_ctcolumn)  := ws_mfiltro;
              ws_vcols                  := ws_vcols    + 1;
		    end loop;
        end loop;


        --linha que afeta o total up da consulta customizada
        if  prm_pvpull.COUNT > 0 and fun.getprop(prm_objeto,'NO_TUP') <> 'S' then
            ws_vcount   := 0;
            loop
                ws_vcount := ws_vcount + 1;
                if  ws_vcount > ws_agrupadores.COUNT then
                    exit;
                end if;
                if  ws_agrupadores(ws_vcount) <> 'PERC_FUNCTION'  then
                    open crs_colunas(ws_agrupadores(ws_vcount));
                    fetch crs_colunas into ws_colunas;
                    close crs_colunas;

                    ws_lquery := ws_lquery + 1;
                    ws_tmp_col := ws_colunas.cd_coluna;
                    if  ws_colunas.tipo='C' then
                        ws_tmp_col := fun.gformula2(prm_micro_visao, ws_colunas.cd_coluna, prm_screen, '', prm_objeto);
                    else
                        ws_tmp_col := '('||ws_tmp_col||')';
                    end if;
                end if;

                if  ws_calculadas > 0 then
                    ws_ct_label                 := ws_ct_label + 1;
                    ws_nm_label(ws_ct_label)    := 'r_'||ws_colunas.cd_coluna||'_'||ws_ct_label;
                    ws_nm_original(ws_ct_label) := ws_colunas.cd_coluna;
                    ws_tp_label(ws_ct_label)    := '3';
                    ws_nlabel                   := '_'||ws_ct_label;
                end if;

                if  rtrim(ws_colunas.st_agrupador) in ('PSM','PCT','CNT') then
                    if  rtrim(ws_colunas.st_agrupador)='PSM' then
                        prm_query_padrao(ws_lquery)     := 'trunc((RATIO_TO_REPORT(SUM('||ws_tmp_col||')) OVER ()*100)) as r_'||ws_colunas.cd_coluna||ws_nlabel||','||crlf;
                    else
                        if  rtrim(ws_colunas.st_agrupador)='CNT' then
                            prm_query_padrao(ws_lquery) := 'COUNT(DISTINCT '||ws_tmp_col||') as r_'||ws_colunas.cd_coluna||','||crlf;   --    ||ws_nlabel  20/04/2022 
                        else
                            prm_query_padrao(ws_lquery) := 'trunc((RATIO_TO_REPORT(COUNT(DISTINCT '||ws_tmp_col||')) OVER ()*100)) as r_'||ws_colunas.cd_coluna||ws_nlabel||','||crlf;
                        end if;
                    end if;
                else
                    prm_query_padrao(ws_lquery) := fcl.fpdata(rtrim(ws_colunas.st_agrupador),'EXT','',rtrim(ws_colunas.st_agrupador))||'('||ws_tmp_col||') As r_'||ws_colunas.cd_coluna||ws_nlabel||','||crlf;
                end if;

                prm_ncolumns(ws_ctcolumn) := ws_colunas.cd_coluna;
                prm_mfiltro(ws_ctcolumn)  := ws_mfiltro;
                ws_ctcolumn := ws_ctcolumn + 1;
                ws_vcols    := ws_vcols    + 1;
            end loop;

        end if;

	    if  nvl(trim(ws_grupo),'%NO_UNDER_GRP%') <> '%NO_UNDER_GRP%' then
            ws_lquery   := ws_lquery + 1;
            prm_query_padrao(ws_lquery) := 'grouping_id('||replace(replace(replace(substr(ws_grupo,1,length(ws_grupo)-1),'group by cube(',''),'group by rollup(',''),'group by (','')||')'||' as UP_GRP_ID';
			prm_ncolumns(ws_ctcolumn)   := 'UP_GRP_MODEL';
            ws_ctcolumn := ws_ctcolumn + 1;


            if  trim(ws_coluna_principal) is not null then
                prm_query_padrao(ws_lquery) := prm_query_padrao(ws_lquery)||', grouping_id('||ws_coluna_principal||') as UP_PRINCIPAL';
                prm_ncolumns(ws_ctcolumn)   := 'UP_PRINCIPAL';
                ws_ctcolumn := ws_ctcolumn + 1;
            end if;

        end if;

        dbms_sql.close_cursor(ws_pcursor);
    end if;


    ws_cd_coluna_ant  := 'NOCHANGE_ID';
    ws_ligacao_ant    := 'NOCHANGE_ID';
    ws_condicao_ant   := 'NOCHANGE_ID';
    ws_indice_ant     := 0;
    ws_initin         := 'NOINIT';
    ws_tmp_condicao   := '';
    ws_noloop         := 'NOLOOP';
    ws_having         := 'having ( ( ';

    open crs_filtro_a( ws_texto,
                       ws_p_micro_visao,
                       ws_p_cd_mapa,
                       ws_p_nr_item,
                       ws_p_cd_padrao,
                       ws_par_function,
                       ws_usuario );
    loop
        fetch crs_filtro_a into ws_filtro_a;
              exit when crs_filtro_a%notfound;

              ws_filtro_a.cd_coluna := ws_col_having(ws_filtro_a.cd_coluna);
              ws_noloop := 'LOOP';
              if  prm_objeto = '%NO_BIND%' then
                  ws_conteudo_comp := chr(39)||ws_conteudo_ant||chr(39);
              else
                  ws_conteudo_comp := ' :b'||trim(to_char(ws_bindn,'0000'));
              end if;

              if  ws_condicao_ant <> 'NOCHANGE_ID' then
                  if  (ws_filtro_a.cd_coluna=ws_cd_coluna_ant and ws_filtro_a.condicao=ws_condicao_ant) and ws_condicao_ant in ('IGUAL','DIFERENTE') then
                      if  ws_initin <> 'BEGIN' then
                          ws_having := ws_having||ws_tmp_condicao;
                          ws_tmp_condicao := '';
                      end if;
                      ws_initin := 'BEGIN';
                      ws_tmp_condicao := ws_tmp_condicao||ws_conteudo_comp||',';
                      ws_bindn := ws_bindn + 1;
                  else
                      if  ws_initin = 'BEGIN' then
                          ws_tmp_condicao := ws_tmp_condicao||ws_conteudo_comp||',';
                          ws_tmp_condicao := substr(ws_tmp_condicao,1,length(ws_tmp_condicao)-1);
                          ws_having := ws_having||ws_cd_coluna_ant||fcl.fpdata(ws_condicao_ant,'IGUAL',' IN ',' NOT IN ')||'('||ws_tmp_condicao||') '||ws_ligacao_ant||crlf;
                          ws_tmp_condicao := '';
                          ws_initin := 'NOINIT';
                      else
                          ws_having := ws_having||ws_tmp_condicao;
                          ws_tmp_condicao := '';
                          if  ws_filtro_a.ligacao <> ws_ligacao_ant then
                              ws_tmp_condicao := ws_tmp_condicao||ws_cd_coluna_ant||ws_tcondicao||ws_conteudo_comp||' ) '||ws_ligacao_ant||' ( '||crlf;
                          else
                              ws_tmp_condicao := ws_tmp_condicao||ws_cd_coluna_ant||ws_tcondicao||ws_conteudo_comp||' '||ws_ligacao_ant||' '||crlf;
                          end if;
                      end if;
                      ws_bindn := ws_bindn + 1;
                  end if;
              end if;

              ws_cd_coluna_ant := ws_filtro_a.cd_coluna;
              ws_condicao_ant  := ws_filtro_a.condicao;
              ws_indice_ant    := ws_filtro_a.indice;
              ws_ligacao_ant   := ws_filtro_a.ligacao;
              ws_conteudo_ant  := ws_filtro_a.conteudo;

              case ws_condicao_ant
                  when 'IGUAL'        then ws_tcondicao := '=';
                  when 'DIFERENTE'    then ws_tcondicao := '<>';
                  when 'MAIOR'        then ws_tcondicao := '>';
                  when 'MENOR'        then ws_tcondicao := '<';
                  when 'MAIOROUIGUAL' then ws_tcondicao := '>=';
                  when 'MENOROUIGUAL' then ws_tcondicao := '<=';
                  when 'LIKE'         then ws_tcondicao := ' like ';
                  when 'NOTLIKE'      then ws_tcondicao := ' not like ';
                  else                ws_tcondicao      := '***';
              end case;
    end loop;
    close crs_filtro_a;

    if  prm_objeto = '%NO_BIND%' then
        ws_conteudo_comp := chr(39)||ws_conteudo_ant||chr(39);
    else
        ws_conteudo_comp := ' :b'||trim(to_char(ws_bindn,'0000'));
    end if;

    if  ws_noloop <> 'NOLOOP' then
        if  ws_initin = 'BEGIN' then
            ws_tmp_condicao := ws_tmp_condicao||ws_conteudo_comp||',';
            ws_tmp_condicao := substr(ws_tmp_condicao,1,length(ws_tmp_condicao)-1);
            ws_having := ws_having||ws_cd_coluna_ant||fcl.fpdata(ws_condicao_ant,'IGUAL',' IN ',' NOT IN ')||'('||ws_tmp_condicao||')'||crlf;
            ws_bindn := ws_bindn + 1;
        else
            ws_tmp_condicao := ws_tmp_condicao||ws_cd_coluna_ant||ws_tcondicao||ws_conteudo_comp||crlf;
            ws_having := ws_having||ws_tmp_condicao;
            ws_bindn := ws_bindn + 1;
        end if;
    end if;

    if  substr(ws_having,length(ws_having)-3, 3) ='( (' then
        ws_having := substr(ws_having,1,length(ws_having)-10)||crlf;
    else
        ws_having := ws_having||' ) ) ';
    end if;

    ws_grupo := substr(ws_grupo,1,length(ws_grupo)-1);

    if  prm_rp in ('ROLL','GROUP') /*and prm_ordem <> 'X' and substr(prm_ordem,1,4) <> 'DRE='*/ then
        begin 
            if  prm_rp = 'ROLL' then
                if  nvl(trim(ws_gord_r),'SEM') = 'SEM' then
                    ws_ordem := 'order by '||ws_gorder||nvl(prm_ordem, '1');
                else
                    ws_ordem := 'order by '||ws_gorder||nvl(prm_ordem, '1')||', '||ws_gord_r||nvl(prm_ordem, '1');
                end if;
            else
                ws_ordem := 'order by '||nvl(prm_ordem, '1');
            end if;
        exception when others then
            ws_ordem := 'order by 1';
        end;
    else
        ws_ordem := '';
    end if;

    if  prm_rp = 'SUMARY' then
        ws_grupo  := '';
        ws_endgrp := '';
    else
        ws_endgrp := ') ';
    end if;

    if  prm_rp = 'PIZZA' then
        ws_endgrp := '';
        ws_ordem  := 'order by '||prm_coluna;
        ws_grupo  := 'group by '||prm_coluna;
    end if;

    ws_top_n := to_number(nvl(fun.getprop(prm_objeto,'AMOSTRA'), 0));

    -- Alterado para retirar o ) que inicia o order by - 11/05/2022  
    if  prm_ordem = 'Y' then
        ws_endgrp := '';
        begin
            begin
                select propriedade into ws_ordem_user from object_attrib where cd_object = prm_objeto and cd_prop = 'ORDEM' and owner = ws_usuario;
                ws_ordem  := ' order by '||ws_ordem_user;
            exception when others then
	            ws_ordem  := ' order by '||fun.getprop(prm_objeto,'ORDEM', prm_usuario => 'DWU');
            end;
        exception when others then
            ws_ordem  := ' order by 1';
        end;

        ws_grupo  := 'group by '||ws_coluna_principal;
    else
        ws_ordem  := ws_ordem||' ';     -- Alterado para retirar o ) que finaliza o order by - 11/05/2022  
    end if;

    if  substr(ws_having,1,1) ='h' and substr(ws_having,1,6) <> 'having' then
        ws_having := '';
    end if;

    if  ws_having='having ( ( ' then
        ws_having := '';
    end if;

    begin 
        ws_versao_oracle := fun.ret_var('ORACLE_VERSION');
    exception when others then   
        ws_versao_oracle := 9999;
    end; 

    PRM_QUERY_PADRAO(1) := 'select '||WS_DISTINTOS||CRLF; 

    if nvl(fun.getprop(prm_objeto, 'AMOSTRA'), 0) <> 0 and ws_versao_oracle >= 12 then
        ws_limited_query := ' fetch first '||fun.getprop(prm_objeto, 'AMOSTRA')||' rows only  ';

        -- PRM_QUERY_PADRAO(1) := 'select '||WS_DISTINTOS||CRLF;    -- Retirado "select * from (" e o Hint: + FIRST_ROWS('||fun.getprop(prm_objeto, 'AMOSTRA')||') 
        -- Se o ultimo caracter da ordem for ) coloca o fetch first dentro, junto com a ordem 
        -- if substr(trim(ws_ordem),length(trim(ws_ordem)), 1) = ')' then                          -- Comentado pois o ws_ordem não tem mais o ) no final 
        --    ws_ordem := substr(trim(ws_ordem), 1, length(trim(ws_ordem))-1 ) ||' ' ;
        --    ws_limited_query := ws_limited_query ||') ';
        -- end if; 

    else

        ws_limited_query := '';
        -- PRM_QUERY_PADRAO(1) := 'select '||WS_DISTINTOS||CRLF;

    end if;

    prm_query_padrao(ws_lquery) := substr(prm_query_padrao(ws_lquery),1,length(prm_query_padrao(ws_lquery))-3)||crlf;

    --prm_query_padrao(ws_lquery) := substr(prm_query_padrao(ws_lquery),1,length(prm_query_padrao(ws_lquery))-3)||crlf;

    ws_lquery := ws_lquery + 1;

    if  nvl(trim(ws_par_function),'no_par') <> 'no_par' then
        prm_query_padrao(ws_lquery) := 'from table('||ws_opttable||'('||ws_par_function||')) '||crlf||ws_condicoes||ws_grupo||ws_endgrp||ws_ordem||ws_limited_query||crlf;
    else
        if length(ws_filtro_geral) > 0 then
		    prm_query_padrao(ws_lquery) := 'from (select * from '||ws_opttable||' where '||ws_filtro_geral||') '||crlf||ws_condicoes||ws_grupo||ws_endgrp||ws_having||ws_ordem||ws_limited_query||crlf;
        else
		    prm_query_padrao(ws_lquery) := 'from '||ws_opttable||' '||crlf||ws_condicoes||ws_grupo||ws_endgrp||ws_having||ws_ordem||ws_limited_query||crlf;
		end if;
	end if;

    prm_linhas := ws_lquery;

    if  ws_calculadas > 0 then
        ws_lquery := 0;
        begin
             ws_counter := 1;
             loop
                 if  ws_counter > prm_query_padrao.COUNT then
                     exit;
                 end if;
                 ws_prm_query_padrao(ws_counter) := prm_query_padrao(ws_counter);
                 ws_counter := ws_counter + 1;

             end loop;
        end;

        ws_lquery := ws_lquery + 1;
        prm_query_padrao(ws_lquery) :='with TABELA_X as (';

        begin
             ws_counter := 1;
             loop
                 if  ws_counter > ws_prm_query_padrao.COUNT then
                     exit;
                 end if;

                 ws_lquery := ws_lquery + 1;
                 prm_query_padrao(ws_lquery) := ws_prm_query_padrao(ws_counter);
                 ws_counter := ws_counter + 1;
             end loop;
        end;

        ws_lquery := ws_lquery + 1;
        prm_query_padrao(ws_lquery) := ') select * from ( select ';

        ws_virgula := '';
        begin
            ws_counter := 0;
            loop
                if  ws_counter > (ws_nm_label.COUNT-1) then
                    exit;
                end if;
                ws_counter := ws_counter + 1;
                ws_lquery  := ws_lquery  + 1;
                prm_query_padrao(ws_lquery) := ws_virgula||' '||ws_nm_label(ws_counter);
                ws_virgula := ',';
            end loop;

            ws_counter := ws_counter + 1;
            ws_lquery  := ws_lquery  + 1;
            prm_query_padrao(ws_lquery) := ws_virgula||' UP_GRP_ID';
            ws_counter := ws_counter + 1;
            ws_lquery  := ws_lquery  + 1;
            prm_query_padrao(ws_lquery) := ws_virgula||' UP_PRINCI';

        end;

        ws_lquery := ws_lquery + 1;
        prm_query_padrao(ws_lquery) := ' from TABELA_X ';

        ws_virgula := '';
        open crs_lcalc;
        loop
            fetch crs_lcalc into ws_lcalc;
                  exit when crs_lcalc%notfound;

                  ws_lquery := ws_lquery + 1;
                  prm_query_padrao(ws_lquery) := ' union all SELECT ';

                  ws_counter := 0;
                  ws_identificador := ' ';
                  loop
                      if  ws_counter > (ws_nm_label.COUNT-1) then
                          exit;
                      end if;

                      ws_counter := ws_counter + 1;
                      if  ws_tp_label(ws_counter)='1' and ws_nm_original(ws_counter) = ws_lcalc.cd_coluna then
                          ws_identificador := ws_nm_label(ws_counter);
                      end if;
                  end loop;

                  ws_counter := 0;
                  ws_virgula := ' ';
                  loop
                      if  ws_counter > (ws_nm_label.COUNT-1) then
                          exit;
                      end if;

                      ws_counter := ws_counter + 1;
                      ws_lquery  := ws_lquery  + 1;

    	              case ws_tp_label(ws_counter)
                                              when '1' then
                                                            if  ws_nm_original(ws_counter) = ws_lcalc.cd_coluna then
                                                                if ws_nm_label.COUNT > 1 then
                                                                    prm_query_padrao(ws_lquery) :=  ws_virgula||chr(39)||ws_lcalc.cd_coluna_show||chr(39);
                                                                else
                                                                    prm_query_padrao(ws_lquery) :=  ws_virgula||chr(39)||ws_lcalc.ds_coluna_show||chr(39);
                                                                end if;
                                                            else
                                                                prm_query_padrao(ws_lquery) := ws_virgula||chr(39)||'['||ws_nm_original(ws_ct_label)||']=['||ws_lcalc.cd_coluna||']'||chr(39);
                                                            end if;
                                              when '2' then
                                                            if  ws_nm_original(ws_counter) = ws_lcalc.cd_coluna then
                                                                prm_query_padrao(ws_lquery) := ws_virgula||chr(39)||ws_lcalc.ds_coluna_show||chr(39);
                                                            else
                                                                prm_query_padrao(ws_lquery) := ws_virgula||chr(39)||'['||ws_nm_original(ws_ct_label)||']=['||ws_lcalc.cd_coluna||']'||chr(39);
                                                           end if;
                                              when '3' then
                                                           prm_query_padrao(ws_lquery) := ws_virgula||'sum('||fun.GL_CALCULADA(ws_lcalc.ds_formula,ws_identificador,ws_nm_label(ws_counter), prm_micro_visao)||')';
                                              else
                                                           prm_query_padrao(ws_lquery) := ws_virgula||chr(39)||'.'||chr(39);
                    end case;
                    ws_virgula := ',';
                  end loop;

                  ws_counter := ws_counter + 1;
                  ws_lquery  := ws_lquery  + 1;
                  prm_query_padrao(ws_lquery) := ws_virgula||' 0 as UP_GRP_ID';
                  ws_counter := ws_counter + 1;
                  ws_lquery  := ws_lquery  + 1;
                  prm_query_padrao(ws_lquery) := ws_virgula||' 0 as UP_PRINCI';

                  ws_lquery := ws_lquery + 1;
                  prm_query_padrao(ws_lquery) := ' from TABELA_X';
	    end loop;
        close crs_lcalc;
        
        prm_query_padrao(ws_lquery) := prm_query_padrao(ws_lquery)||' ) order by 1';

    end if;

    prm_linhas := ws_lquery;

    
    if  prm_cross = 'S' then
        ws_lquery := 0;
        begin
             ws_counter := 1;
             loop
                 if  ws_counter > prm_query_padrao.COUNT then
                     exit;
                 end if;
                 ws_prm_query_padrao(ws_counter) := prm_query_padrao(ws_counter);
                 ws_counter := ws_counter + 1;

             end loop;
        end;


        ws_lquery := ws_lquery + 1;
        prm_query_padrao(ws_lquery) :='select * from ( WITH TABELA_BASE AS ( ';

        begin
             ws_counter := 1;
             loop
                 if  ws_counter > ws_prm_query_padrao.COUNT then
                     exit;
                 end if;

                 ws_lquery := ws_lquery + 1;
                 prm_query_padrao(ws_lquery) := ws_prm_query_padrao(ws_counter);

                 

                 ws_counter := ws_counter + 1;
             end loop;
        end;

        
        ws_lquery := ws_lquery + 1;
        prm_query_padrao(ws_lquery) := ' )  select * from ( ';

        ws_unionall := '';
        ws_vcount := 0;
        loop
            ws_vcount := ws_vcount + 1;
            if  ws_vcount > ws_agrupadores.COUNT then
                exit;
            end if;

            ws_lquery := ws_lquery + 1;

            prm_query_padrao(ws_lquery) := ws_unionall||'SELECT R_'||prm_coluna||' AS R_'||prm_coluna||', '||chr(39)||to_char(ws_vcount,'000')||'-'||ws_agrupadores(ws_vcount)||chr(39)||' AS '||prm_coluna||', R_'||ws_agrupadores(ws_vcount)||'     AS R_VALOR FROM TABELA_BASE ';

            ws_unionall := ' UNION ALL ';
        end loop;
        ws_cursor := 'select distinct '||prm_coluna||' from '||ws_opttable||' '||ws_condicoes||' order by '||prm_coluna;

        
        
        ws_pcursor := dbms_sql.open_cursor;



        dbms_sql.parse(ws_pcursor, ws_cursor, dbms_sql.native);
        dbms_sql.define_column(ws_pcursor, 1, ret_lcross, 400);
        ws_nulo := core.bind_direct(prm_condicoes, ws_pcursor, '', prm_objeto, prm_micro_visao, prm_screen);
        ws_linhas := dbms_sql.execute(ws_pcursor);
        ws_lquery := ws_lquery + 1;
        prm_query_padrao(ws_lquery) := ' )) pivot ( sum(R_VALOR) for R_'||prm_coluna||' in ( ';

        prm_cab_cross := prm_coluna;
        prm_ncolumns(1) := prm_coluna;
        ws_vcount       := 1;
        ws_virgula := '';
        
    

        loop
            ws_linhas := dbms_sql.fetch_rows(ws_pcursor);
            if  ws_linhas = 1 then
                ws_vazio := False;
            else
                if  ws_vazio = True then
                    dbms_sql.close_cursor(ws_pcursor);
                    raise ws_nodata;
                end if;
                exit;
            end if;

            dbms_sql.column_value(ws_pcursor, 1, ret_lcross);
            ws_lquery                   := ws_lquery + 1;
            ws_vcount                   := ws_vcount + 1;
            prm_query_padrao(ws_lquery) := ws_virgula||chr(39)||ret_lcross||chr(39);
            begin
                prm_cab_cross               := prm_cab_cross||'|'||ret_lcross;
            exception when others then
                insert into bi_log_sistema values(sysdate, 'Erro de cross', ws_usuario, 'ERRO');
                commit;
                exit;
            end;
            prm_ncolumns(ws_vcount)     := ret_lcross;

            ws_virgula := ',';
        end loop;
        ws_lquery := ws_lquery + 1;
        prm_query_padrao(ws_lquery) := ')) order by 1';
        prm_linhas := ws_lquery;
        dbms_sql.close_cursor(ws_pcursor);
    end if;
   
    return ('X');
    
exception 
    when ws_nodata then
        insert into bi_log_sistema values(sysdate, 'Sem dados! - MONTA', ws_usuario, 'ERRO');
        commit;
        return 'Sem Dados';
    when ws_nouser then
        insert into bi_log_sistema values(sysdate, 'Sem permiss&atilde;o! - MONTA', ws_usuario, 'ERRO');
        commit;
    when others then
        insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - MONTA', ws_usuario, 'ERRO');
        commit;
end MONTA_QUERY_DIRECT;

FUNCTION BIND_DIRECT (	prm_condicoes	 varchar2	default null,
						prm_cursor  	 number     default 0,
						prm_tipo		 varchar2	default null,
						prm_objeto		 varchar2	default null,
						prm_micro_visao	 varchar2	default null,
						prm_screen       varchar2   default null,
                        prm_no_having    varchar2   default 'S' ) return varchar2 as

	cursor crs_filtrog ( p_condicoes varchar2,
	                     p_vpar      varchar2,
                         prm_usuario varchar2 ) is

	                select distinct * from ( 
					               select
					                      'DWU' as cd_usuario,
                                          trim(prm_micro_visao)                 as micro_visao,
                                          trim(cd_coluna)                       as cd_coluna,
                                          'DIFERENTE'                           as condicao,
                                          replace(trim(CONTEUDO), '$[NOT]', '') as conteudo,
                                          'and'                                 as ligacao,
                                          'float_filter_item'                   as tipo
                                   from   FLOAT_FILTER_ITEM
                                   where
                                        trim(cd_usuario) = prm_usuario and
                                        trim(screen) = trim(prm_screen) and
										instr(trim(conteudo), '$[NOT]') <> 0 and
                                        trim(cd_coluna) not in (select cd_coluna from filtros where condicao = 'NOFLOAT' and trim(micro_visao) = trim(prm_micro_visao) and trim(cd_objeto) = trim(prm_objeto) and tp_filtro = 'objeto') and
                                        trim(cd_coluna) in ( select trim(CD_COLUNA)
                                                               from   MICRO_COLUNA mc
                                                               where  trim(mc.CD_MICRO_VISAO)=trim(prm_micro_visao) and
															   trim(mc.cd_coluna) not in (select distinct nvl(trim(cd_coluna), 'N/A') from table(fun.vpipe_par(p_condicoes)))
															 ) and fun.getprop(prm_objeto,'FILTRO_FLOAT') = 'N'
								   
								   union all
								   
								   select
					                      'DWU' as cd_usuario,
                                          trim(prm_micro_visao) as micro_visao,
                                          trim(cd_coluna)       as cd_coluna,
                                          'IGUAL'               as condicao,
                                          trim(CONTEUDO)     as conteudo,
                                          'and'                 as ligacao,
                                          'float_filter_item'   as tipo
                                   from   FLOAT_FILTER_ITEM
                                   where
                                        trim(cd_usuario) = prm_usuario and
                                        trim(screen) = trim(prm_screen) and
										instr(trim(conteudo), '$[NOT]') = 0 and
                                        trim(cd_coluna) not in (select cd_coluna from filtros where condicao = 'NOFLOAT' and trim(micro_visao) = trim(prm_micro_visao) and trim(cd_objeto) = trim(prm_objeto) and tp_filtro = 'objeto') and
                                        trim(cd_coluna) in ( select trim(CD_COLUNA)
                                                               from   MICRO_COLUNA mc
                                                               where  trim(mc.CD_MICRO_VISAO)=trim(prm_micro_visao) and
															   trim(mc.cd_coluna) not in (select distinct nvl(trim(cd_coluna), 'N/A') from table(fun.vpipe_par(p_condicoes)))
															 ) and fun.getprop(prm_objeto,'FILTRO_FLOAT') = 'N'
								union all
	                select 'DWU'                 as cd_usuario,
	                       trim(prm_micro_visao) as micro_visao,
	                       trim(cd_coluna)       as cd_coluna,
	                       cd_condicao               as condicao,
	                       trim(CD_CONTEUDO)     as conteudo,
	                       'and'                 as ligacao,
                           'condicoes'           as tipo
	                       from table(fun.vpipe_par(p_condicoes)) pc where cd_coluna <> '1' and 
						   (
                           (trim(cd_coluna) in (
                               select trim(CD_COLUNA) from MICRO_COLUNA where trim(CD_MICRO_VISAO)=trim(prm_micro_visao) and

                         
						   
						   trim(cd_coluna)||trim(cd_conteudo) not in (
								select nof.cd_coluna||nof.conteudo from  filtros nof
								where  trim(nof.micro_visao) = trim(prm_micro_visao) and 
								trim(nof.condicao) = 'NOFILTER' and 
								trim(nof.conteudo) = trim(pc.cd_conteudo) and 
								trim(nof.cd_objeto) = trim(prm_objeto)
						   )
                                
						   union all
							 select trim(CD_COLUNA) from MICRO_VISAO_FPAR where  trim(CD_MICRO_VISAO)=trim(prm_micro_visao))
							 and fun.getprop(prm_objeto,'FILTRO_DRILL') = 'N'
                           ) or prm_objeto like ('COBJ%') ) and
                           trim(cd_coluna)||trim(cd_conteudo) not in (
								select nof.cd_coluna||nof.conteudo from  filtros nof
								where  trim(nof.micro_visao) = trim(prm_micro_visao) and 
								trim(nof.condicao) = 'NOFILTER' and 
								trim(nof.conteudo) = trim(pc.cd_conteudo) and 
								trim(nof.cd_objeto) = trim(prm_objeto)
						   )
                        union all
			/*select	rtrim(cd_usuario)	as cd_usuario,
				rtrim(micro_visao)	as micro_visao,
				rtrim(cd_coluna)	as cd_coluna,
				rtrim(condicao)		as condicao,
				rtrim(conteudo)		as conteudo,
				rtrim(ligacao)		as ligacao,
                'filtros_geral'     as tipo
			from 	FILTROS t1
			where	rtrim(micro_visao) = rtrim(prm_micro_visao) and 
                st_agrupado='N' and
                tp_filtro = 'geral' and
				(rtrim(cd_usuario)  in (prm_usuario, 'DWU') or trim(cd_usuario) in (select cd_group  from gusers_itens where cd_usuario = prm_usuario))
			union*/
			select	trim(cd_usuario)	as cd_usuario,
				rtrim(micro_visao)	as micro_visao,
				rtrim(cd_coluna)	as cd_coluna,
				rtrim(condicao)		as condicao,
				rtrim(conteudo)		as conteudo,
				rtrim(ligacao)		as ligacao,
                'filtros_objeto'    as tipo
			from 	FILTROS
			where	trim(micro_visao) = trim(prm_micro_visao) and 
            st_agrupado='N' and 
            condicao <> 'NOFLOAT' and
			condicao <> 'NOFILTER' AND
            (
                rtrim(cd_objeto) = trim(prm_objeto) or
                (
                    rtrim(cd_objeto) = trim(prm_screen) and 
                    nvl(fun.getprop(trim(prm_objeto),'FILTRO'), 'N/A') <> 'ISOLADO' and 
                    nvl(fun.getprop(trim(prm_objeto),'FILTRO'), 'N/A') <> 'COM CORTE' and 
                    fun.getprop(prm_objeto,'FILTRO_TELA') <> 'S' 
                )
			)
			and tp_filtro = 'objeto'
            and trim(cd_usuario)  = 'DWU'
			
		) where not (trim(condicao)='IGUAL' and trim(cd_coluna) in (select trim(cd_coluna) from table(fun.vpipe_par(p_vpar))))
               order   by tipo, cd_usuario, micro_visao, cd_coluna, condicao, conteudo;

	ws_filtrog	crs_filtrog%rowtype;

	cursor crs_filtrogf ( p_condicoes varchar2,
	                      p_vpar      varchar2,
                          prm_usuario varchar2 ) is
                  select * from (
	                select distinct  *
   	                                   from (
	                select 'DWU'                 as cd_usuario,
	                       trim(prm_micro_visao) as micro_visao,
	                       trim(cd_coluna)       as cd_coluna,
	                       cd_condicao               as condicao,
	                       trim(CD_CONTEUDO)     as conteudo,
	                       'and'                 as ligacao
	                       from table(fun.vpipe_par(p_condicoes)) where cd_coluna <> '1' and trim(cd_coluna) in (select trim(CD_COLUNA) from MICRO_COLUNA     where trim(CD_MICRO_VISAO)=trim(prm_micro_visao) union all
	                                                                                                         select trim(CD_COLUNA) from MICRO_VISAO_FPAR where  trim(CD_MICRO_VISAO)=trim(prm_micro_visao))
                        union all
			select	trim(cd_usuario)	as cd_usuario,
				rtrim(micro_visao)	as micro_visao,
				rtrim(cd_coluna)	as cd_coluna,
				rtrim(condicao)		as condicao,
				rtrim(conteudo)		as conteudo,
				rtrim(ligacao)		as ligacao
			from 	FILTROS t1
			where	rtrim(micro_visao) = rtrim(prm_micro_visao) and
			    tp_filtro = 'geral' and
				(rtrim(cd_usuario)  in (prm_usuario, 'DWU') or trim(cd_usuario) in (select cd_group from gusers_itens where cd_usuario = prm_usuario))
			union
			select	trim(cd_usuario)	as cd_usuario,
				rtrim(micro_visao)	as micro_visao,
				rtrim(cd_coluna)	as cd_coluna,
				rtrim(condicao)		as condicao,
				rtrim(conteudo)		as conteudo,
				rtrim(ligacao)		as ligacao
			from 	FILTROS
			where	trim(micro_visao) = trim(prm_micro_visao) and 
			tp_filtro = 'objeto' and 
            condicao <> 'NOFLOAT' and
            (
             trim(cd_objeto) = trim(prm_objeto) or
            (trim(cd_objeto) = trim(prm_screen) and fun.GETPROP(trim(prm_objeto),'FILTRO')<>'ISOLADO')
            ) and
				trim(cd_usuario)  = 'DWU')
                                where   (trim(condicao)='IGUAL' and trim(cd_coluna) in (select trim(cd_coluna) from table(fun.vpipe_par(p_vpar))))
) where
                            not (trim(cd_coluna) not in (Select distinct Cd_Coluna from MICRO_VISAO_FPAR where cd_micro_visao = prm_micro_visao) and fun.getprop(prm_objeto,'FILTRO')='ISOLADO')
				order   by cd_coluna;

	ws_filtrogf	crs_filtrogf%rowtype;

cursor crs_filtro_a ( p_condicoes    varchar2,
                      p_vpar         varchar2,
                      prm_usuario    varchar2 ) is

                        select distinct * from (
                                  select 'C'                     as indice,
                                         rtrim(cd_usuario)       as cd_usuario,
                                         rtrim(micro_visao)      as micro_visao,
                                         rtrim(cd_coluna)        as cd_coluna,
                                         rtrim(condicao)         as condicao,
                                         rtrim(conteudo)         as conteudo,
                                         rtrim(ligacao)          as ligacao
                                  from   FILTROS t1
                                  where  rtrim(micro_visao) = rtrim(prm_micro_visao) and
                                         tp_filtro = 'geral' and
                                         (rtrim(cd_usuario) in (prm_usuario, 'DWU') or trim(cd_usuario) in (select cd_group from gusers_itens where cd_usuario = prm_usuario)) and
                                         st_agrupado='S'
                        union all
                                  select 'C'                     as indice,
                                         rtrim(cd_usuario)       as cd_usuario,
                                         rtrim(micro_visao)      as micro_visao,
                                         rtrim(cd_coluna)        as cd_coluna,
                                         rtrim(condicao)         as condicao,
                                         rtrim(conteudo)         as conteudo,
                                         rtrim(ligacao)          as ligacao
                                  from   FILTROS
                                  where  trim(micro_visao) = trim(prm_micro_visao) and st_agrupado='S' and
                                         tp_filtro = 'objeto' and
                                         trim(cd_objeto)   in (trim(prm_objeto), trim(prm_screen)) and
                                         condicao <> 'NOFLOAT' and
                                         trim(cd_usuario)  = 'DWU')
                        where   not ( trim(condicao)='IGUAL' and trim(cd_coluna) in (select trim(cd_coluna) from table(fun.vpipe_par(p_vpar))))
                        order   by cd_usuario, micro_visao, cd_coluna, condicao, conteudo;

   ws_filtro_a	crs_filtro_a%rowtype;

	cursor crs_fpar is
                        Select
                        Cd_Micro_Visao,
                        Cd_Coluna,
                        Cd_parametro
                        from   MICRO_VISAO_FPAR
                        where
	                       cd_micro_visao = prm_micro_visao
	                order by cd_coluna;

	ws_fpar		crs_fpar%rowtype;

	ws_par_function  varchar2(32000);
    ws_pipe                 char(1);
	ws_bindn		number;
	ws_distintos	varchar2(32000);
	ws_texto		varchar2(32000);
	ws_textot		varchar2(32000);
	ws_nm_var		varchar2(8000);
	ws_ct_var		varchar2(8000);
	ws_null			varchar2(8000);
	ws_tcont		varchar2(200);

	ws_cursor	integer;
	ws_linhas	integer;

	ws_calculado	varchar2(32000);
	ws_sql		    varchar2(32000);

	crlf VARCHAR2( 2 ):= CHR( 13 ) || CHR( 10 );

    ws_nulo varchar2(1) := null;
	
	ws_binds varchar2(3000);

    ws_usuario varchar2(80);

begin

    ws_usuario := gbl.getUsuario;

	ws_bindn := 1;
	
	ws_texto := replace(prm_condicoes, '||', '|');

    if instr(ws_texto, '|', -1) = length(ws_texto) then
      ws_texto := substr(ws_texto, 0, instr(ws_texto, '|', -1)-1);
    end if;

	if  prm_tipo = 'SUMARY' then
	    ws_null  := substr(ws_texto, 1 ,instr(ws_texto,'|')-1);
	    ws_texto := replace(ws_texto, ws_null||'|', '');
	end if;

        ws_par_function := '';
        ws_pipe := '';

    open crs_fpar;
	    loop
            fetch crs_fpar into ws_fpar;
            exit when crs_fpar%notfound;

            ws_par_function := ws_par_function||ws_pipe||ws_fpar.cd_coluna||'|'||ws_fpar.cd_parametro;
            ws_pipe         := '|';

        end loop;
    close crs_fpar;


	open crs_filtrog(ws_texto, ws_par_function, ws_usuario);
        loop
            fetch crs_filtrog into ws_filtrog;
            exit when crs_filtrog%notfound;

            ws_tcont := ws_filtrog.conteudo;

            if  UPPER(substr(ws_tcont,1,5)) = 'EXEC=' then
                ws_tcont := fun.xexec(ws_tcont, prm_screen);
            end if;

            if  UPPER(substr(ws_tcont,1,8)) = 'SUBEXEC=' then
                ws_tcont := fun.xexec(fun.subpar(ws_tcont, prm_screen, 'N'), prm_screen);
            end if;

            if  substr(ws_tcont,1,2) = '$[' then
                ws_tcont := fun.gparametro(ws_tcont);
            end if;

            if  substr(ws_tcont,1,2) = '#[' then
                ws_tcont := fun.ret_var(ws_tcont, ws_usuario);
            end if;

            if  substr(ws_tcont,1,2) = '@[' then
                ws_tcont := fun.gvalor(ws_tcont, prm_screen);
            end if;

            ws_binds := ws_binds||'|'||ws_tcont;

            DBMS_SQL.BIND_VARIABLE(prm_cursor, ':b'||ltrim(to_char(ws_bindn,'0000')), ws_tcont);

            ws_bindn := ws_bindn + 1;

        end loop;
	close crs_filtrog;


	open crs_filtrogf(ws_texto, ws_par_function, ws_usuario);
	loop
	     fetch crs_filtrogf into ws_filtrogf;
		   exit when crs_filtrogf%notfound;

	            ws_tcont := ws_filtrogf.conteudo;

	            if UPPER(substr(ws_tcont,1,5)) = 'EXEC=' then
	                ws_tcont := fun.xexec(ws_tcont, prm_screen);
	            end if;

                if UPPER(substr(ws_tcont,1,8)) = 'SUBEXEC=' then
                    ws_tcont := fun.xexec(fun.subpar(ws_tcont, prm_screen, 'N'), prm_screen);
                end if;
               
                if  substr(ws_tcont,1,2) = '$[' then
	                ws_tcont := fun.gparametro(ws_tcont);
	            end if;

                if substr(ws_tcont,1,2) = '#[' then
	                ws_tcont := fun.ret_var(ws_tcont, ws_usuario);
	            end if;

	           
			    ws_binds := ws_binds||'|'||ws_tcont;

                DBMS_SQL.BIND_VARIABLE(prm_cursor, ':b'||ltrim(to_char(ws_bindn,'0000')), ws_tcont);
               
	           ws_bindn := ws_bindn + 1;

        end loop;
        close crs_filtrogf;

	    open crs_filtro_a(ws_texto, ws_par_function, ws_usuario);
	     loop
	    fetch crs_filtro_a into ws_filtro_a;
		  exit when crs_filtro_a%notfound;

	    ws_tcont := ws_filtro_a.conteudo;

	    if  substr(ws_tcont,1,2) = '$[' then
	        ws_tcont := fun.gparametro(ws_tcont);
	    end if;

        if  substr(ws_tcont,1,2) = '#[' then
	        ws_tcont := fun.ret_var(ws_tcont, ws_usuario);
	    end if;

	    if  UPPER(substr(ws_tcont,1,5)) = 'EXEC=' then
	        ws_tcont := fun.xexec(ws_tcont, prm_screen);
	    end if;

         if  UPPER(substr(ws_tcont,1,5)) = 'SUBEXEC=' then
	        ws_tcont := fun.xexec(fun.subpar(ws_tcont, prm_screen, 'N'), prm_screen);
	    end if;
		
		ws_binds := ws_binds||'|'||ws_tcont;

	    DBMS_SQL.BIND_VARIABLE(prm_cursor, ':b'||ltrim(to_char(ws_bindn,'0000')), ws_tcont);

	    ws_bindn := ws_bindn + 1;

	    end loop;
	    close crs_filtro_a;
		
  return ('Binds Carregadas='||ws_binds);
  
exception
	when others then
        insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BIND_DIRECT '||prm_cursor, ws_usuario, 'ERRO');
        commit;
end BIND_DIRECT;

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
					   prm_acumulado     in varchar2 default null ) return varchar2 as

	cursor crs_colunas is
			select	
            trim(cd_coluna) 	as cd_coluna,
            trim(cd_ligacao)	as cd_ligacao,
            trim(tipo)    		as tipo,
			trim(formula)		as formula,
            trim(tipo_input)    as input,
			data_type           as tipo_column
			from 	DATA_COLUNA, all_tab_columns
			where	trim(cd_micro_data) = trim(prm_objeto) and
             
            column_name = cd_coluna and
            table_name = trim(prm_micro_data)
            order by st_chave desc, ordem asc, rownum asc;

	ws_colunas	crs_colunas%rowtype;

	cursor crs_tabela is
			select	nm_tabela
			from 	MICRO_DATA
			where	nm_micro_DATA = prm_objeto;

	ws_tabela	crs_tabela%rowtype;

	type generic_cursor is 		ref cursor;

	crs_saida			generic_cursor;


    cursor crs_filtrog(prm_usuario varchar2)  is
            select
	           rtrim(cd_usuario)	as cd_usuario,
				rtrim(micro_visao)	as micro_visao,
				rtrim(cd_coluna)	as cd_coluna,
				rtrim(condicao)		as condicao,
				rtrim(conteudo)		as conteudo,
				rtrim(ligacao)		as ligacao
			from 	FILTROS
			where st_agrupado='N' and
			tp_filtro = 'objeto' and
            trim(cd_objeto)   = trim(prm_objeto) and 
            (trim(cd_usuario)  = prm_usuario or cd_usuario = 'DWU' or cd_usuario in (select cd_group from gusers_itens where cd_usuario = prm_usuario)) and
            condicao <> 'IGUAL' and 
            condicao <> 'NOFLOAT'
			order by cd_usuario, micro_visao, cd_coluna, condicao, conteudo;

	ws_filtrog	crs_filtrog%rowtype;

    cursor crs_filtrogin(prm_usuario varchar2)  is
            select
	           rtrim(cd_usuario)	as cd_usuario,
				rtrim(micro_visao)	as micro_visao,
				rtrim(cd_coluna)	as cd_coluna,
				rtrim(condicao)		as condicao,
				rtrim(conteudo)		as conteudo,
				rtrim(ligacao)		as ligacao
			from 	FILTROS
			where	st_agrupado='N' and
			tp_filtro = 'objeto' and
            trim(cd_objeto) = trim(prm_objeto) and 
            (trim(cd_usuario)  = prm_usuario or cd_usuario = 'DWU') and
            condicao = 'IGUAL' and 
            condicao <> 'NOFLOAT'
			order by condicao, cd_coluna, cd_usuario, micro_visao, cd_coluna, conteudo;

	ws_filtrogin	crs_filtrogin%rowtype;

	ws_counter       number := 1;
    ws_final         number := 0;
    ws_limite        number := 0;
    ws_coluna        number := 0;
	ws_virgula       char(1);

    ws_linha_inicio  number;
    ws_linha_final   number;

	ws_cursor	     integer;
	ws_linhas	     integer;
    ws_retorno       varchar2(400);
	ws_sql		     varchar2(2000);

	ws_distintos     long;
	crlf             VARCHAR2( 2 ):= CHR( 13 ) || CHR( 10 );
	ws_queryoc       VARCHAR2(4000);

    ws_nulo          varchar2(1) := null;

    ws_colunasf      long;
    ws_tcont		 varchar2(400);
    ws_bindn         number;
    ws_conteudo_comp varchar2(1400);
    ws_conteudo_ant  varchar2(800);
    ws_condicao      varchar2(800);
    ws_coluna_ant    varchar2(800);
    ws_condicao_ant  varchar2(80);
    ws_countin       number;
    ws_count         number;
    WS_conteudo      varchar2(1000);
	ws_tipo          varchar2(200);
	ws_chave         varchar2(200);
	ws_acumulado     varchar2(1400);
    ws_ligacao       varchar2(200);
    ws_busca_dt      date;
    ws_busca         varchar2(200);
    ws_usuario       varchar2(80);

begin

    ws_usuario := gbl.getUsuario;

    htp.p(ws_nulo);

	ws_distintos	   := ' ';

	open crs_tabela;
	fetch crs_tabela into ws_tabela;
	close crs_tabela;

    /*Montagem de colunas*/

	ws_distintos := '';
    ws_virgula   := '';

   
    open crs_colunas;
	loop

        fetch crs_colunas into ws_colunas;
	              exit when crs_colunas%notfound;

        ws_coluna   := ws_coluna + 1;
	    if ws_colunas.input = 'file' then
            ws_distintos := ws_distintos||ws_virgula||' '''' as '||ws_colunas.cd_coluna;
        elsif (ws_colunas.input = 'data' or ws_colunas.input = 'datatime') and ws_colunas.tipo_column = 'DATE' then
            /*ws_distintos := ws_distintos||ws_virgula||' '||ws_colunas.cd_coluna||'';
			testar se varchar ou date na tabela*/
			begin
			    ws_distintos := ws_distintos||ws_virgula||' trim(to_char('||ws_colunas.cd_coluna||', ''DD/MM/YYYY HH24:MI'')) as '||ws_colunas.cd_coluna||'';
            exception when others then
			    ws_distintos := ws_distintos||ws_virgula||' '||ws_colunas.cd_coluna||'';
			end;
		else
		    ws_distintos := ws_distintos||ws_virgula||' '||ws_colunas.cd_coluna||'';
		end if;
        prm_ncolumns(ws_coluna) := ws_colunas.cd_coluna;
        
	    ws_virgula   := ',';

	end loop;
	close crs_colunas;

    open crs_filtrog(ws_usuario);
		loop
		    fetch crs_filtrog into ws_filtrog;
			exit when crs_filtrog%notfound;

		    ws_tcont := ws_filtrog.conteudo;
		    
            if  UPPER(substr(ws_tcont,1,5)) = 'EXEC=' then
		        ws_tcont := fun.xexec(ws_tcont, prm_screen);
		    end if;

            if  UPPER(substr(ws_tcont,1,8)) = 'SUBEXEC=' then
                ws_tcont := fun.xexec(fun.subpar(ws_tcont, prm_screen, 'N'), prm_screen);
            end if;
			
		    if  substr(ws_tcont,1,2) = '$[' then
		        ws_tcont := fun.gparametro(ws_tcont);
		    end if;

            if  substr(ws_tcont,1,2) = '#[' then
		        ws_tcont := fun.ret_var(ws_tcont, ws_usuario);
		    end if;

            case ws_filtrog.condicao
                when 'IGUAL'        then ws_condicao := '=';
                when 'DIFERENTE'    then ws_condicao := '<>';
                when 'MAIOR'        then ws_condicao := '>';
                when 'MENOR'        then ws_condicao := '<';
                when 'MAIOROUIGUAL' then ws_condicao := '>=';
                when 'MENOROUIGUAL' then ws_condicao := '<=';
                when 'LIKE'         then ws_condicao := ' like ';
                when 'NOTLIKE'      then ws_condicao := ' not like ';
                else                     ws_condicao := '=';
            end case;
                
              
                
            /*if ws_filtrog.condicao in('LIKE', 'NOTLIKE') then
                ws_conteudo_comp := ws_conteudo_comp||' '||ws_filtrog.cd_coluna||' '||ws_condicao||' ''%'||WS_conteudo||'%'' AND'; 
            else
                ws_conteudo_comp := ws_conteudo_comp||' nvl('||ws_filtrog.cd_coluna||', ''N/A'') '||ws_condicao||' nvl('||WS_conteudo||', ''N/A'') AND';
            end if;*/
                
            if WS_FILTROG.CONDICAO IN('LIKE', 'NOTLIKE') THEN
                WS_CONTEUDO_COMP := WS_CONTEUDO_COMP||' '||WS_FILTROG.CD_COLUNA||' '||WS_CONDICAO||' ''%'||ws_tcont||'%'' AND'; 
            else
                WS_CONTEUDO_COMP := WS_CONTEUDO_COMP||' '||WS_FILTROG.CD_COLUNA||' '||WS_CONDICAO||'  '''||ws_tcont||''' AND';
            end if;

		end loop;
	close crs_filtrog;
		
	ws_conteudo_comp := substr(ws_conteudo_comp, 1, length(ws_conteudo_comp)-3);

    ws_conteudo_ant := '';
    ws_countin := 0;
        
    open crs_filtrogin(ws_usuario);
	    loop
		    fetch crs_filtrogin into ws_filtrogin;
			exit when crs_filtrogin%notfound;

            ws_tcont := ws_filtrogin.conteudo;

            if  UPPER(substr(ws_tcont,1,5)) = 'EXEC=' then
		        ws_tcont := fun.xexec(ws_tcont, prm_screen);
		    end if;

            if  UPPER(substr(ws_tcont,1,8)) = 'SUBEXEC=' then
                ws_tcont := fun.xexec(fun.subpar(ws_tcont, prm_screen, 'N'), prm_screen);
            end if;

		    if  substr(ws_tcont,1,2) = '$[' then
		        ws_tcont := fun.gparametro(ws_tcont);
		    end if;

            if  substr(ws_tcont,1,2) = '#[' then
		        ws_tcont := fun.ret_var(ws_tcont, ws_usuario);
		    end if;        

            if ws_countin = 0 then
                ws_conteudo_ant := ' '||ws_filtrogin.cd_coluna||' in ('''||ws_tcont||''' ';
                ws_coluna_ant := ws_filtrogin.cd_coluna;
            elsif ws_filtrogin.cd_coluna = ws_coluna_ant then
                ws_conteudo_ant := ws_conteudo_ant||', '''||ws_tcont||''' ';
            else
                ws_conteudo_ant := ws_conteudo_ant||') and '||ws_filtrogin.cd_coluna||' in ('''||ws_tcont||''' ';
                ws_coluna_ant := ws_filtrogin.cd_coluna;
            end if;

            ws_countin := ws_countin+1;

		end loop;
	close crs_filtrogin;

    if length(ws_conteudo_ant) > 3 then
        if length(ws_conteudo_comp) > 3 then
            ws_conteudo_comp := ws_conteudo_comp||' and '||ws_conteudo_ant||')';
        else
            ws_conteudo_comp := ws_conteudo_ant||')';
        end if;
    end if;

    ws_colunasf := ws_distintos||', DWU_ROWID, DWU_ROWNUM ';
    ws_distintos := ws_distintos||', ROWID AS DWU_ROWID ';

    ws_coluna   := ws_coluna + 1;
    prm_ncolumns(ws_coluna) := 'DWU_ROWID';
    ws_coluna   := ws_coluna + 1;
    prm_ncolumns(ws_coluna) := 'DWU_ROWNUM';

    if prm_count = true then
        prm_query_padrao(1) := 'select count(*) as contador '||crlf;
    else
	    prm_query_padrao(1) := 'select * from (select a.*, ROWNUM AS DWU_ROWNUM from ( select /*+ FIRST_ROWS('||nvl(prm_limite, fun.getprop(prm_objeto, 'LINHAS', 'DEFAULT', ws_usuario))||') */ '||ws_distintos||crlf;
	end if;

    prm_query_padrao(2) := 'FROM '||ws_tabela.nm_tabela||crlf||' WHERE ';

    ws_coluna_ant   := 'N/A';
    ws_condicao_ant := 'N/A';

	/* teste de filtro acumulado */
	for i in(select cd_coluna, cd_conteudo, cd_condicao from table((fun.vpipe_par(prm_acumulado))) order by cd_coluna, cd_condicao ) loop

        select cd_ligacao into ws_ligacao from data_coluna where cd_coluna = i.cd_coluna and cd_micro_data = trim(prm_objeto);

        if ((i.cd_coluna <> ws_coluna_ant or i.cd_condicao <> ws_condicao_ant) and ws_coluna_ant <> 'N/A') or (i.cd_condicao <> 'IGUAL' and ws_coluna_ant <> 'N/A') then
            ws_acumulado := ws_acumulado||') and ';
        end if;

		if i.cd_coluna = ws_coluna_ant and i.cd_condicao = ws_condicao_ant and i.cd_condicao = 'IGUAL' then
            ws_acumulado := ws_acumulado||','''||UPPER(trim(i.cd_conteudo))||''''||crlf;
        elsif i.cd_condicao = 'IGUAL' then
		    ws_acumulado := ws_acumulado||' upper('||trim(i.cd_coluna)||') in ('''||UPPER(trim(i.cd_conteudo))||''''||crlf;
            --ws_acumulado := ws_acumulado||'(upper('||trim(i.cd_coluna)||') in ('''||UPPER(trim(i.cd_conteudo))||''' or upper('||trim(i.cd_coluna)||') = '''||fun.cdesc(UPPER(trim(i.cd_conteudo)), ws_ligacao, true)||''') and '||crlf;
        elsif i.cd_condicao = 'MAIOR' then 
            --com upper, convertendo para string os números
            --ws_acumulado := ws_acumulado||' (upper('||trim(i.cd_coluna)||') >= '''||UPPER(trim(i.cd_conteudo))||''' or upper('||trim(i.cd_coluna)||') >= '''||fun.cdesc(UPPER(trim(i.cd_conteudo)), ws_ligacao, true)||''' '||crlf;
            ws_acumulado := ws_acumulado||' (('||trim(i.cd_coluna)||') >= '||(trim(i.cd_conteudo))||' '||crlf;

        elsif i.cd_condicao = 'NULO' then
            ws_acumulado := ws_acumulado||' '||trim(i.cd_coluna)||' is null and '||crlf;
        elsif i.cd_condicao = 'NNULO' then
            ws_acumulado := ws_acumulado||' '||trim(i.cd_coluna)||' is not null and '||crlf;
		elsif i.cd_condicao = 'LIKE' then
            ws_acumulado := ws_acumulado||' (upper('||trim(i.cd_coluna)||') LIKE (''%'||UPPER(trim(i.cd_conteudo))||'%'') or upper('||trim(i.cd_coluna)||') LIKE (''%'||fun.cdesc(UPPER(trim(i.cd_conteudo)), ws_ligacao, true)||'%'') '||crlf;
        else
	        ws_acumulado := ws_acumulado||' (upper('||trim(i.cd_coluna)||') NOT LIKE (''%'||UPPER(trim(i.cd_conteudo))||'%'') and upper('||trim(i.cd_coluna)||') NOT LIKE (''%'||fun.cdesc(UPPER(trim(i.cd_conteudo)), ws_ligacao, true)||'%'') '||crlf;
		end if;

        ws_coluna_ant   := i.cd_coluna;
        ws_condicao_ant := i.cd_condicao;

	end loop;

    ws_acumulado := ws_acumulado||')';

	if nvl(ws_acumulado, ')') <> ')' then

        prm_query_padrao(3) := substr(trim(ws_acumulado), 0, length(trim(ws_acumulado)));

    else

        if length(prm_busca) > 0 then
            if length(ws_conteudo_comp) > 3 then
                ws_conteudo_comp := 'and '||ws_conteudo_comp;
            end if;
            
            select data_type into ws_tipo from ALL_TAB_COLUMNS where  TABLE_NAME = ws_tabela.nm_tabela and column_name = prm_chave;
            
            if ws_tipo = 'DATE' then
                begin
                    ws_chave := prm_chave;
                    ws_busca_dt := to_date(prm_busca, 'DD/MM/YYYY');
                exception when others then
                    ws_chave := '(upper('||trim(prm_chave)||'))';
                    ws_busca := UPPER(trim(prm_busca));
                end;

                if prm_condicao = 'igual' then
                    prm_query_padrao(3) := '('||ws_chave||' = '''||ws_busca_dt||''' or '||ws_chave||' = '''||fun.cdesc(ws_busca_dt, ws_ligacao, true)||''') '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'maior' then 
                    prm_query_padrao(3) := '('||ws_chave||' >= '''||ws_busca_dt||''' or '||ws_chave||' >= '''||fun.cdesc(ws_busca_dt, ws_ligacao, true)||''') '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'nulo' then
                    prm_query_padrao(3) := ws_chave||' is null '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'nnulo' then
                    prm_query_padrao(3) := ws_chave||' is not null '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'semelhante' then
                    prm_query_padrao(3) := '('||ws_chave||' LIKE (''%'||ws_busca_dt||'%'') or '||ws_chave||' LIKE (''%'||fun.cdesc(ws_busca_dt, ws_ligacao, true)||'%'')) '||ws_conteudo_comp||' '||crlf;
                else
                    prm_query_padrao(3) := '('||ws_chave||' NOT LIKE (''%'||ws_busca_dt||'%'') and '||ws_chave||' NOT LIKE (''%'||fun.cdesc(ws_busca_dt, ws_ligacao, true)||'%'')) '||ws_conteudo_comp||' '||crlf;
                end if;

            elsif ws_tipo = 'NUMBER' then

                begin
                    ws_chave := prm_chave;
                    ws_busca := to_number(prm_busca);
                exception when others then
                    ws_chave := prm_chave;
                    ws_busca := prm_busca;
                end;

                if prm_condicao = 'igual' then
                    prm_query_padrao(3) := '('||ws_chave||' = '||ws_busca||' or '||ws_chave||' = '''||fun.cdesc(ws_busca, ws_ligacao, true)||''') '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'maior' then 
                    prm_query_padrao(3) := '('||ws_chave||' >= '||ws_busca||' or '||ws_chave||' >= '''||fun.cdesc(ws_busca, ws_ligacao, true)||''') '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'nulo' then
                    prm_query_padrao(3) := ws_chave||' is null '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'nnulo' then
                    prm_query_padrao(3) := ws_chave||' is not null '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'semelhante' then
                    prm_query_padrao(3) := '('||ws_chave||' LIKE (''%'||ws_busca||'%'') or '||ws_chave||' LIKE (''%'||fun.cdesc(ws_busca, ws_ligacao, true)||'%'')) '||ws_conteudo_comp||' '||crlf;
                else
                    prm_query_padrao(3) := '('||ws_chave||' NOT LIKE (''%'||ws_busca||'%'') and '||ws_chave||' NOT LIKE (''%'||fun.cdesc(ws_busca, ws_ligacao, true)||'%'')) '||ws_conteudo_comp||' '||crlf;
                end if;

            else
                ws_chave := '(upper('||trim(prm_chave)||'))';
                ws_busca := UPPER(trim(prm_busca));

                if prm_condicao = 'igual' then
                    prm_query_padrao(3) := '('||ws_chave||' = '''||ws_busca||''' or '||ws_chave||' = '''||fun.cdesc(ws_busca, ws_ligacao, true)||''') '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'maior' then 
                    prm_query_padrao(3) := '('||ws_chave||' >= '''||ws_busca||''' or '||ws_chave||' >= '''||fun.cdesc(ws_busca, ws_ligacao, true)||''') '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'nulo' then
                    prm_query_padrao(3) := ws_chave||' is null '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'nnulo' then
                    prm_query_padrao(3) := ws_chave||' is not null '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'semelhante' then
                    prm_query_padrao(3) := '('||ws_chave||' LIKE (''%'||ws_busca||'%'') or '||ws_chave||' LIKE (''%'||fun.cdesc(ws_busca, ws_ligacao, true)||'%'')) '||ws_conteudo_comp||' '||crlf;
                else
                    prm_query_padrao(3) := '('||ws_chave||' NOT LIKE (''%'||ws_busca||'%'') and '||ws_chave||' NOT LIKE (''%'||fun.cdesc(ws_busca, ws_ligacao, true)||'%'')) '||ws_conteudo_comp||' '||crlf;
                end if;


            end if;

        else
            if length(ws_conteudo_comp) > 3 then
                prm_query_padrao(3) := ws_conteudo_comp;
            else
                prm_query_padrao(3) := '1=1 ';
            end if;
        end if;

    end if;

    if prm_count = true then
        prm_query_padrao(4) := ''||crlf;
    else
        prm_query_padrao(4) := ' ORDER BY '||nvl(fun.getprop(prm_objeto, 'DIRECTION', 'DEFAULT', ws_usuario), 1)||crlf;
    end if;	

    /************** 
      Era utilizado somente para a direção >>, alterado para utilizar a quantidade de registros passada pelo Backend (Javascript) - 07/02/2022 
    begin
        ws_sql := 'select count(*) from '||ws_tabela.nm_tabela;
 	    ws_cursor := dbms_sql.open_cursor;
	    dbms_sql.parse(ws_cursor, ws_sql, DBMS_SQL.NATIVE);
	    dbms_sql.define_column(ws_cursor, 1, ws_retorno, 200);
	    ws_linhas := dbms_sql.execute(ws_cursor);
	    ws_linhas := dbms_sql.fetch_rows(ws_cursor);
	    dbms_sql.column_value(ws_cursor, 1, ws_retorno);
	    dbms_sql.close_cursor(ws_cursor);
        ws_final         := to_number(ws_retorno);
        prm_limite_final := to_number(ws_retorno);
    exception
        when others then 
            ws_final         := 0;
            prm_limite_final := 0;
    end;
    *****************************/ 
    
 	case
		when PRM_direcao = '>'  then 
            ws_linha_inicio := (prm_referencia+1);
            ws_linha_final  := (prm_referencia+prm_limite);
	 	when prm_direcao = '>>' then 
            -- Aterado para usar os limites passados por parâmetro pelo Frontend - 07/02/2022 
            --ws_linha_inicio := abs((ws_final-(prm_limite-1)));
            --ws_linha_final  := ws_final;
            ws_linha_inicio := (prm_referencia+1);
            ws_linha_final  := (prm_referencia+prm_limite);
		when PRM_direcao = '<'  then
            if  (prm_referencia-prm_limite) < 1 then
                ws_linha_inicio := 1;
                ws_linha_final  := (prm_referencia-1);
            else
                ws_linha_inicio := abs((prm_referencia-prm_limite));
                ws_linha_final  := (prm_referencia-1);
            end if;
		when prm_direcao = '<<' then 
            ws_linha_inicio := 1;
            ws_linha_final  := prm_limite;						   
	else 
		ws_linha_inicio := 1;
        ws_linha_final  := prm_limite;
	end case;

    if prm_count = true then
        prm_query_padrao(5) := '';
    else
	    prm_query_padrao(5) := ' ) a where rownum <= '||ws_linha_final||' ) where DWU_ROWNUM >= '||ws_linha_inicio||' order by '||nvl(fun.getprop(prm_objeto, 'DIRECTION', 'DEFAULT', ws_usuario), 1);
	end if;
    
    prm_linhas := 5;
    ws_count := 0;

	return ('X');

exception
	when others then
        insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BIND_DIRECT ', ws_usuario, 'ERRO');
        commit;
	    return ('['||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||']');
end DATA_DIRECT;




FUNCTION CDESC_SQL ( prm_tabela  char default null,
                     prm_coluna  char default null,   
                     prm_reverse boolean default false ) return varchar2 as


    cursor crs_cdesc is
        select nds_tfisica, nds_cd_codigo, nds_cd_empresa, nds_cd_descricao
          from CODIGO_DESCRICAO
         where nds_tabela = upper(prm_tabela);
    ws_cdesc crs_cdesc%rowtype;
    ws_sql  varchar2(2000);
begin

    ws_cdesc.nds_tfisica := null;
    Open  crs_cdesc;
    Fetch crs_cdesc into ws_cdesc;
    close crs_cdesc;

    if ws_cdesc.nds_tfisica is null then 
        ws_sql := 'SEM TAUX';
    else 
        if prm_reverse = false then
            ws_sql := '(NVL((select '||rtrim(ws_cdesc.nds_cd_descricao)||' from '||ws_cdesc.nds_tfisica||' where '||ws_cdesc.nds_tfisica||'.'||ws_cdesc.nds_cd_codigo||' = '||prm_coluna||'), '||prm_coluna||'))';
        else
            ws_sql := '(NVL((select '||rtrim(ws_cdesc.nds_cd_codigo)||' from '||ws_cdesc.nds_tfisica||' where '||ws_cdesc.nds_tfisica||'.'||ws_cdesc.nds_cd_descricao||' = '||prm_coluna||'), '||prm_coluna||'))';
        end if;
    end if;    
    
    return(ws_sql);

exception when others then
       return('ERRO TAUX');
end CDESC_SQL;












end CORE;
/
show error