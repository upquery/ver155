create or replace TRIGGER AUTO_UPDATE 
BEFORE DELETE OR INSERT OR UPDATE OF CD_PROP,CD_TIPO,GRUPO,HINT,LABEL,ORDEM,SCRIPT,ST_PERSONALIZADO,SUFIXO,TP_OBJETO,VALIDACAO,VL_DEFAULT ON BI_OBJECT_PADRAO 
BEGIN
  update bi_auto_update set ultimo_update = sysdate where tipo = 'PADROES';
END;

create or replace trigger AUTO_UPDATE_OBJ AFTER DDL ON DATABASE
BEGIN
if ora_dict_obj_name in ('AUX', 'BRO', 'COM', 'CORE', 'FCL', 'FUN', 'GBL', 'IMPORT', 'OBJ', 'UPLOAD', 'UPQUERY', 'UP_REL') then
  update bi_auto_update set ultimo_update = sysdate where tipo = ora_dict_obj_name;
end if;
END;

create or replace TRIGGER AUTO_UPDATE_FILE 
BEFORE DELETE OR INSERT OR UPDATE ON tab_documentos 
for each row
DECLARE 
  ws_name varchar2(80);
BEGIN
  ws_name := :NEW.name;
  if ws_name = 'default-min.js' then
    update bi_auto_update set ultimo_update = sysdate where tipo = 'JS';
  end if;
  if ws_name = 'default-min.css' then
    update bi_auto_update set ultimo_update = sysdate where tipo = 'CSS';
  end if;
END;