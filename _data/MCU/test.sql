
select *
from [staging-mcu2]
where [order] = 11
and character_n not in(select character_n from nodes_exclude)
--and actor = 'Maya Stojan'

update [staging-mcu2] set [rank] = 10
where [rank] = 20

select character_n,count(*),sum([rank])
from [staging-mcu2]
where character_n not in(select character_n from nodes_exclude)
group by character_n
order by sum([rank]) desc

select * from [staging-mcu2]
where character_n not in(select character_n from nodes_exclude)
and character_n like('%murdock%')
and actor = 'Michelle Hurd'


select * from nodes
where aname = 'Michelle Hurd'
--where id in (3902,3725,3731)

select * from edges
where source in(103)
