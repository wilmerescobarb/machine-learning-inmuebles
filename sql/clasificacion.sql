-- Estrategia de relleno - limpieza - set clasificacion.
-- Aprendizaje Automático
-- Escobar - Estrada - Vaca

--Columna geoname_num
update "tpFinal_clasificacion" set geoname_num = 3436521 where lugar = 'Abasto';
update "tpFinal_clasificacion" set geoname_num = 10288645 where lugar = 'Las Canitas';
update "tpFinal_clasificacion" set geoname_num = (select ge.geoname_num from "tpFinal_clasificacion" ge where ge.lugar like 'Palermo' limit 1) where lugar = 'Palermo Chico';
update "tpFinal_clasificacion" set geoname_num = 7602284 where lugar like 'Palermo Hollywood';
update "tpFinal_clasificacion" set geoname_num = (select ge.geoname_num from "tpFinal_clasificacion" ge where ge.lugar like 'Palermo' limit 1) where lugar = 'Palermo Viejo';
update "tpFinal_clasificacion" set geoname_num = 8426315 where lugar = 'Parque Avellaneda';
update "tpFinal_clasificacion" set geoname_num = 11151441 where lugar = 'Parque Centenario';
update "tpFinal_clasificacion" set geoname_num = (select ge.geoname_num from "tpFinal_clasificacion" ge where ge.lugar like 'San Nicolas' limit 1) where lugar = 'Tribunales';
update "tpFinal_clasificacion" set geoname_num = 6526203 where lugar = 'Catalinas';

--Columna sup_tot_m2
update "tpFinal_clasificacion" set sup_tot_m2 = sup_cub_m2 where sup_tot_m2 is null and sup_cub_m2 is not null;
--Columna sup_cub_m2
update "tpFinal_clasificacion" set sup_cub_m2 = sup_tot_m2 where sup_cub_m2 is null and sup_tot_m2 is not null;
--Columna sup_tot_m2 nulos
update "tpFinal_clasificacion" set sup_tot_m2 = sub.promedio from
(select tp.lugar, round(avg(tp.sup_tot_m2)) promedio from "tpFinal_clasificacion" tp where tp.sup_tot_m2 is not null group by tp.lugar) sub
where "tpFinal_clasificacion".lugar=sub.lugar and "tpFinal_clasificacion".sup_tot_m2 is null;
--Columna sup_cub_m2 nulos
update "tpFinal_clasificacion" set sup_cub_m2 = sub.promedio from
(select tp.lugar, round(avg(tp.sup_cub_m2)) promedio from "tpFinal_clasificacion" tp where tp.sup_cub_m2 is not null group by tp.lugar) sub
where "tpFinal_clasificacion".lugar=sub.lugar and "tpFinal_clasificacion".sup_cub_m2 is null;

--Columna piso con valores mayores a 60 no nulos
update "tpFinal_clasificacion" set piso = round(piso/100) where piso is not null and piso > 60;
--Columna piso con valores nulos
update "tpFinal_clasificacion" set piso = subq.piso from (
select e.lugar, round(avg(e.piso)) as piso from "tpFinal_clasificacion" e group by e.lugar) subq
where subq.lugar = "tpFinal_clasificacion".lugar and "tpFinal_clasificacion".piso is null;
--Columna piso lugar sin informacion.
update "tpFinal_clasificacion" set piso = 1 where piso is null;

--Columna cant_amb con numero al comienzo de descripcion.
update "tpFinal_clasificacion" set cant_amb = subq.regEx::bigint from
(select	distinct id, cant_amb, descripcion,
	(regexp_matches(lower(descripcion), '((^[0-9])\s*amb[^b]+)', 'g'))[2] as regEx from "tpFinal_clasificacion"
) subq where subq.id = "tpFinal_clasificacion".id and "tpFinal_clasificacion".cant_amb is null;
--Columna cant_amb entre 0 - 9 en descripcion.
update "tpFinal_clasificacion" set cant_amb = subq.regEx::bigint from
(select	distinct id, cant_amb, descripcion,
	(regexp_matches(lower(descripcion), '((\s[0-9])\s*amb[^b]+)', 'g'))[2] as regEx from "tpFinal_clasificacion"
) subq where subq.id = "tpFinal_clasificacion".id and "tpFinal_clasificacion".cant_amb is null;
--Columna cant_amb sin espacio antes del numero en descripcion.
update "tpFinal_clasificacion" set cant_amb = subq.regEx::bigint from
(select	distinct id, cant_amb, descripcion,
	(regexp_matches(lower(descripcion), '(([1-9])\s*amb[^b]+)', 'g'))[2] as regEx from "tpFinal_clasificacion"
) subq where subq.id = "tpFinal_clasificacion".id and "tpFinal_clasificacion".cant_amb is null;
--Columna cant_amb numeros de dos digitos en descripcion.
update "tpFinal_clasificacion" set cant_amb = subq.regEx::bigint from
(select	distinct id, cant_amb, descripcion,
	(regexp_matches(lower(descripcion), '((\s[0123456789]{1,2})\s*amb[^b]+)', 'g'))[2] as regEx from "tpFinal_clasificacion"
) subq where subq.id = "tpFinal_clasificacion".id and "tpFinal_clasificacion".cant_amb is null;
--Columna cant_amb con cantidad escrita en letras en descripcion.
update "tpFinal_clasificacion" set cant_amb = 1 where cant_amb is null and lower(descripcion) similar to '%(mono_amb|monoamb|un_amb)%';
update "tpFinal_clasificacion" set cant_amb = 2 where cant_amb is null and lower(descripcion) similar to '%(dos_amb)%';
update "tpFinal_clasificacion" set cant_amb = 3 where cant_amb is null and lower(descripcion) similar to '%(tres_amb)%';
--Columna cant_amb con : en descripcion.
update "tpFinal_clasificacion" set cant_amb = subq.regEx::bigint from
(select	distinct id, cant_amb, descripcion,
	(regexp_matches(lower(descripcion), '((amb|ambiente|ambientes):[^b]([1-9]))', 'g'))[3] as regEx from "tpFinal_clasificacion"
) subq where subq.id = "tpFinal_clasificacion".id and "tpFinal_clasificacion".cant_amb is null;
update "tpFinal_clasificacion" set cant_amb = subq.regEx::bigint from
(select	distinct id, cant_amb, descripcion,
	(regexp_matches(lower(descripcion), '((amb|ambiente|ambientes):([1-9]))', 'g'))[3] as regEx from "tpFinal_clasificacion"
) subq where subq.id = "tpFinal_clasificacion".id and "tpFinal_clasificacion".cant_amb is null;
--Columna cant_amb sin cadena amb en descripcion.
update "tpFinal_clasificacion" set cant_amb = 1 where cant_amb is null and lower(descripcion) not similar to '%(mbient|_mbient)%';
--Columna cant_amb sin valor numerico o en letras.
update "tpFinal_clasificacion" set cant_amb = 1 where cant_amb is null;

--Adicion columna distancia_minima_subte
alter table "tpFinal_clasificacion" add column if not exists distancia_minima_subte numeric;
update "tpFinal_clasificacion" set distancia_minima_subte=(select min(
					ST_distance(
						(ST_MakePoint(lon,lat))::geography,
						(ST_GeomFromText(s.wkt))::geography
					)) from subte s);

--Columna lon/lat sin distancia.
update "tpFinal_clasificacion" tp set lat=subq.lat,lon=subq.lon from (
	select avg(tfe.lat) as lat, avg(tfe.lon) as lon
	from "tpFinal_clasificacion" tfe 
	where lugar = 'Palermo Viejo'
)subq 
where tp.lugar = 'Palermo Viejo' and tp.lat is null and tp.lon is null;
				
--Columna lat, lon nulos
update "tpFinal_clasificacion" set lat=sub.lat,lon=sub.lon 
from( select lugar,max(lat)lat,max(lon)lon,count(*) from "tpFinal_clasificacion"
where distancia_minima_subte < 50000 group by lugar )sub
where  "tpFinal_clasificacion".lat is null and "tpFinal_clasificacion".lugar=sub.lugar;
--Columna lat, lon inconsistentes
update "tpFinal_clasificacion" set lat=sub.lat,lon=sub.lon 
from( select lugar,max(lat)lat,max(lon)lon,count(*) from "tpFinal_clasificacion"
where distancia_minima_subte < 50000
group by lugar )sub
where  distancia_minima_subte > 50000 and "tpFinal_clasificacion".lugar=sub.lugar;

--Columna distancia_minima_subte
update  "tpFinal_clasificacion" set distancia_minima_subte=(select min(
					ST_distance(
						(ST_MakePoint(lon,lat))::geography,
						(ST_GeomFromText(s.wkt))::geography
					)) from subte s);

--Creacion columnas adicionales
alter table "tpFinal_clasificacion" add column if not exists distancia_minima_hospitales numeric;
alter table "tpFinal_clasificacion" add column if not exists distancia_minima_culturales numeric;
alter table "tpFinal_clasificacion" add column if not exists distancia_minima_publicos numeric;
alter table "tpFinal_clasificacion" add column if not exists distancia_minima_iglesias numeric;
alter table "tpFinal_clasificacion" add column if not exists distancia_minima_gastronomicos numeric;
alter table "tpFinal_clasificacion" add column if not exists distancia_minima_universidades numeric;

--Columna hospitales
update "tpFinal_clasificacion" set distancia_minima_hospitales=(select min(
					ST_distance(
						(ST_MakePoint(lon,lat))::geography,
						(ST_GeomFromText(h."WKT"))::geography
					)) from "hospitales" h);

--Columna culturales
update "tpFinal_clasificacion" set distancia_minima_culturales=(select min(
					ST_distance(
						(ST_MakePoint(lon,lat))::geography,
						(ST_MakePoint(e."LONGITUD", e."LATITUD"))::geography
					)) from "espacios-culturales" e);

--Columna publicos
alter table "espacio-verde-publico" add column if not exists wkt_text TEXT;
update "espacio-verde-publico" e set wkt_text = ST_AsText(ST_Centroid(ST_GeomFromText(e."WKT")));
update "tpFinal_clasificacion" set distancia_minima_publicos=(select min(
					ST_distance(
						(ST_MakePoint(lon,lat))::geography,
						(ST_GeomFromText(e.wkt_text))::geography
					)) from "espacio-verde-publico" e);

--Columna iglesias
update "tpFinal_clasificacion" set distancia_minima_iglesias=(select min(
					ST_distance(
						(ST_MakePoint(lon,lat))::geography,
						(ST_MakePoint(i.long,i.lat))::geography
					)) from "iglesias" i);

--Columna gastronomicos
update "tpFinal_clasificacion" set distancia_minima_gastronomicos=(select min(
					ST_distance(
						(ST_MakePoint(lon,lat))::geography,
						(ST_MakePoint(o.long,o.lat))::geography
					)) from "oferta_gastronomica" o);

--Columna universidades
update "tpFinal_clasificacion" set distancia_minima_universidades=(select min(
					ST_distance(
						(ST_MakePoint(lon,lat))::geography,
						(ST_GeomFromText(u."WKT_gkba"))::geography
					)) from "universidades" u);

--Columna clase cerca o lejos subte
alter table "tpFinal_clasificacion" add column if not exists proximo_subte TEXT;
update "tpFinal_clasificacion" set proximo_subte= case 
	when distancia_minima_subte <= 200 then 'MUY CERCA'
	when distancia_minima_subte > 200 and  distancia_minima_subte <= 1000 then 'CERCA'	
	else 'LEJOS'
end;

--Columna clase cerca o lejos hosp
alter table "tpFinal_clasificacion" add column if not exists proximo_hosp TEXT;
update "tpFinal_clasificacion" set proximo_hosp= case
	when distancia_minima_hospitales <= 200 then 'MUY CERCA'
	when distancia_minima_hospitales > 200 and  distancia_minima_hospitales <= 1000 then 'CERCA'	
	else 'LEJOS'
end;

--Columna clase cerca o lejos cult
alter table "tpFinal_clasificacion" add column if not exists proximo_cult TEXT;
update "tpFinal_clasificacion" set proximo_cult= case 
	when distancia_minima_culturales <= 200 then 'MUY CERCA'
	when distancia_minima_culturales > 200 and  distancia_minima_culturales <= 1000 then 'CERCA'	
	else 'LEJOS'
end;

--Columna clase cerca o lejos publ
alter table "tpFinal_clasificacion" add column if not exists proximo_publ TEXT;
update "tpFinal_clasificacion" set proximo_publ= case 
	when distancia_minima_publicos <= 200 then 'MUY CERCA'
	when distancia_minima_publicos > 200 and  distancia_minima_publicos <= 1000 then 'CERCA'	
	else 'LEJOS'
end;

--Columna clase cerca o lejos igle
alter table "tpFinal_clasificacion" add column if not exists proximo_igle TEXT;
update "tpFinal_clasificacion" set proximo_igle= case 
	when distancia_minima_iglesias <= 200 then 'MUY CERCA'
	when distancia_minima_iglesias > 200 and  distancia_minima_iglesias <= 1000 then 'CERCA'	
	else 'LEJOS'
end;

--Columna clase cerca o lejos gast
alter table "tpFinal_clasificacion" add column if not exists proximo_gast TEXT;
update "tpFinal_clasificacion" set proximo_gast= case 
	when distancia_minima_gastronomicos <= 200 then 'MUY CERCA'
	when distancia_minima_gastronomicos > 200 and  distancia_minima_gastronomicos <= 1000 then 'CERCA'	
	else 'LEJOS'
end;

--Columna clase cerca o lejos univ
alter table "tpFinal_clasificacion" add column if not exists proximo_univ TEXT;
update "tpFinal_clasificacion" set proximo_univ= case 
	when distancia_minima_universidades <= 200 then 'MUY CERCA'
	when distancia_minima_universidades > 200 and  distancia_minima_universidades <= 1000 then 'CERCA'	
	else 'LEJOS'
end;

--Se crean las columnas para comuna
alter table "tpFinal_clasificacion" add column if not exists comuna int;

update "tpFinal_clasificacion" tp set comuna = subq.comuna
from (
	select distinct tfe.lugar, b.comuna from "tpFinal_clasificacion" tfe
	left join barrios b on lower(tfe.lugar) = lower(b.barrio) order by lugar
)subq where tp.comuna is null  and lower(subq.lugar) = lower(tp.lugar);
--
update "tpFinal_clasificacion" set comuna = 14
where lugar in ('Palermo Chico', 'Palermo Hollywood', 'Palermo Soho', 'Palermo Viejo','Las Canitas');
--
update "tpFinal_clasificacion" set comuna = 2
where lugar in ('Abasto', 'Barrio Norte');
--
update "tpFinal_clasificacion" set comuna = 1
where lugar in ('Nunez','Tribunales','Catalinas');
--
update "tpFinal_clasificacion" set comuna = 13
where lugar in ('Capital Federal','Congreso','Centro / Microcentro');
--
update "tpFinal_clasificacion" set comuna = 11
where lugar in ('Once', 'Villa General Mitre');
--
update "tpFinal_clasificacion" set comuna = 6
where lugar in ('Parque Centenario');
--
update "tpFinal_clasificacion" set comuna = 4
where lugar in ('Pompeya');

--Se crean las columnas para bueno_para_vivir
alter table "tpFinal_clasificacion" add column if not exists bueno_para_vivir text;
update "tpFinal_clasificacion" tp set bueno_para_vivir = 
(case
	when lower(lugar) similar to '%(palermo|recoleta|belgrano|caballito|telmo)%' then 'SI'
	else 'NO'
end);

--Columna precio_prom con barrio
alter table "tpFinal_clasificacion" add column if not exists precio_prom TEXT;
update "tpFinal_clasificacion" set precio_prom = subq.precio_prom from (
	select barrio, año, case 
	when round(avg(pvd.precio_prom)) <= 2000 then 'MUY BAJO'
	when round(avg(pvd.precio_prom)) > 2000 and round(avg(pvd.precio_prom)) <= 3000 then 'BAJO'
	when round(avg(pvd.precio_prom)) > 3000 and round(avg(pvd.precio_prom)) <= 4000 then 'MEDIO'
	else 'ALTO' 
	end as precio_prom
	from "precio-venta-deptos" pvd where año between 2012 and 2016 group by pvd.barrio, pvd.año
) subq where "tpFinal_clasificacion".anio = subq.año and lower("tpFinal_clasificacion".lugar) = lower(subq.barrio);

--Columna precio_prom nulos
update "tpFinal_clasificacion" set precio_prom = subq.precio_prom from (
	select comuna, case 
	when round(avg(pvd.precio_prom)) <= 2000 then 'MUY BAJO'
	when round(avg(pvd.precio_prom)) > 2000 and round(avg(pvd.precio_prom)) <= 3000 then 'BAJO'
	when round(avg(pvd.precio_prom)) > 3000 and round(avg(pvd.precio_prom)) <= 4000 then 'MEDIO'
	else 'ALTO' 
	end as precio_prom
	from "precio-venta-deptos" pvd where año between 2012 and 2016 group by pvd.comuna
) subq where "tpFinal_clasificacion".comuna = subq.comuna and "tpFinal_clasificacion".precio_prom is null;

--Columna propiedad
alter table "tpFinal_clasificacion" add column if not exists propiedad TEXT;
update "tpFinal_clasificacion" set propiedad = 'departamento' where tipoprop = 'dto';
update "tpFinal_clasificacion" set propiedad = tipoprop where propiedad is null;