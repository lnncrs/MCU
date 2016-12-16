--==========================================================
--test data
--==========================================================

select *
from [staging-hp]
--where character_n like('%13%')
where actor = 'Emily VanCamp'

select character_n,count(*)
from [staging-hp]
where character_n not in(select character_n from nodes_exclude)
and character_n like('%Hill%')
group by character_n
order by count(*) desc

--==========================================================
--load data
--==========================================================

--=============================
--delete data

--truncate table [dbo].[staging-hp]
truncate table [dbo].[staging-hp]

ALTER TABLE [dbo].[edges] DROP CONSTRAINT [FK_edges_nodes]
ALTER TABLE [dbo].[edges] DROP CONSTRAINT [FK_edges_nodes1]
GO

truncate table nodes
truncate table edges

ALTER TABLE [dbo].[edges]  WITH CHECK ADD  CONSTRAINT [FK_edges_nodes] FOREIGN KEY([source])
REFERENCES [dbo].[nodes] ([id])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[edges] CHECK CONSTRAINT [FK_edges_nodes]
GO

ALTER TABLE [dbo].[edges]  WITH CHECK ADD  CONSTRAINT [FK_edges_nodes1] FOREIGN KEY([target])
REFERENCES [dbo].[nodes] ([id])
GO

ALTER TABLE [dbo].[edges] CHECK CONSTRAINT [FK_edges_nodes1]
GO

--=============================
--insert nodes movies

insert into [dbo].[nodes] (label,morder,myear,aname,[type],mcost,mgross,mprofit,mtomatometer,maudience)
select --(select top 1 movie from mojo where movieptbr = s.movie) as 'label'
       s.[movie] as 'label'
      ,s.[order] as 'morder'
	  ,s.year as 'myear'
	  ,s.movie as 'aname'
	  ,'movie' as 'type'
	  ,0 --(select top 1 cost from mojo where movieptbr = s.movie) as 'mcost'
	  ,0 --(select top 1 gross from mojo where movieptbr = s.movie) as 'mgross'
	  ,0 --(select top 1 (gross-cost) from mojo where movieptbr = s.movie) as 'mprofit'
	  ,0 --(select top 1 mtomatometer from mojo where movieptbr = s.movie) as 'mtomatometer'
	  ,0 --(select top 1 maudience from mojo where movieptbr = s.movie) as 'maudience'
from [staging-hp] as s
group by s.movie,s.[order],s.year
order by s.[order] asc

--insert into [dbo].[nodes] (label,morder,myear,aname,[type],mcost,mgross,mprofit,mtomatometer,maudience)
--select s.movie,s.[order],s.year,s.movie as 'aname','movie' as 'type',0,0,0,0,0 from [staging-hp] as s group by s.movie,s.[order],s.year order by s.[order] asc

update nodes set [type] = 'tvshow' where label in('Agents of S.H.I.E.L.D.','Agent Carter','Daredevil','Jessica Jones')
update nodes set [role] = [type] where [type] in ('movie','tvshow')
update nodes set [rank] = 200 where [type] in ('movie')
update nodes set [rank] = 100 where [type] in ('tvshow')

--update nodes set [mcost] = 1 where [mcost] = 0
--update nodes set [mgross] = 1 where [mgross] = 0
--update nodes set [mprofit] = 1 where [mprofit] = 0
--update nodes set [mtomatometer] = 1 where [mtomatometer] = 0
--update nodes set [maudience] = 1 where [maudience] = 0

--=============================
--insert nodes actors

insert into [dbo].[nodes] (label,morder,myear,aname,[type],[role],[rank])
select s.character_n as 'label'
      ,(select top 1 [order] from [staging-hp] where actor = s.actor order by [order] asc) as 'morder'
	  ,(select top 1 [year] from [staging-hp] where actor = s.actor order by [order] asc) as 'myear'
	  ,s.actor as 'aname'
	  ,'actor' as 'type'
	  ,'' --(select top 1 [role] from [nodes_stars] where character_n = s.character_n) as 'role'
	  ,(select sum([rank]) from [staging-hp] where character_n = s.character_n) as 'rank'
from [staging-hp] as s
--where character_n not in(select character_n from nodes_exclude)
group by s.character_n,s.actor
order by s.character_n asc

update [nodes] set [role] = 'support' where [role] is null

--insert into [dbo].[nodes] (label,morder,myear,aname,type)
--select s.character_n,(select top 1 [order] from [staging-hp] where actor = s.actor order by [order] asc),(select top 1 [year] from [staging-hp] where actor = s.actor order by [order] asc),s.actor,'actor' from [staging-hp] as s group by s.character_n,s.actor order by s.character_n asc

--update [staging-hp] set character_n = [character] where 1=1 
--select s.character_n,(select top 1 [order] from [staging-hp] where actor = s.actor order by [order] asc),(select top 1 [year] from [staging-hp] where actor = s.actor order by [order] asc),s.actor,'actor' from [staging-hp] as s group by s.character_n,s.actor order by s.character_n asc

--=============================
--insert edges

insert into edges ([source],[target],[type])
select (select top 1 id from nodes where aname = s.actor) as 'source',(select top 1 id from nodes where aname = s.movie) as 'target','Directed' as 'type'
from [staging-hp] as s
--where character_n not in(select character_n from nodes_exclude)
--and s.actor = 'Shaun Toub'
order by s.character_n

--insert into edges ([source],[target],[type])
--select (select top 1 id from nodes where aname = s.actor) as 'source',(select top 1 id from nodes where label = s.movie) as 'target','Directed' as 'type' from [staging-hp] as s order by s.character_n

--=============================
--insert other data

/*
INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (0,'Iron Man',2008,'Samuel L. Jackson','Nick Fury','Nick Fury')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (1,'The Incredible Hulk',2008,'Robert Downey Jr.','Tony Stark','Tony Stark / Iron Man')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (3,'Thor',2011,'Samuel L. Jackson','Nick Fury','Nick Fury')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (4,'Captain America: The First Avenger',2011,'Samuel L. Jackson','Nick Fury','Nick Fury')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (5,'The Avengers',2012,'Josh Brolin','Thanos','Thanos')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (6,'Iron Man Three',2013,'Mark Ruffalo','Bruce Banner / The Hulk','Bruce Banner / The Hulk')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (7,'Agents of S.H.I.E.L.D.',2013,'Jaimie Alexander','Sif','Sif')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (8,'Thor: The Dark World',2013,'Benicio Del Toro','The Collector','The Collector')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (9,'Captain America: The Winter Soldier',2014,'Aaron Taylor-Johnson','Pietro Maximoff / Quicksilver','Pietro Maximoff / Quicksilver')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (9,'Captain America: The Winter Soldier',2014,'Elizabeth Olsen','Wanda Maximoff / Scarlet Witch','Wanda Maximoff / Scarlet Witch')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (10,'Guardians of the Galaxy',2014,'Josh Brolin','Thanos','Thanos')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (11,'Agent Carter',2015,'Dominic Cooper','Howard Stark','Howard Stark')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (12,'Daredevil',2015,'Elodie Yung','Elektra Natchios','Elektra Natchios')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (12,'Daredevil',2015,'Rosario Dawson','Claire Temple','Claire Temple')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (12,'Daredevil',2015,'Ayelet Zurer','Vanessa Marianna','Vanessa Marianna')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (12,'Daredevil',2015,'Vondie Curtis-Hall','Ben Urich','Ben Urich')  

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (13,'Avengers: Age of Ultron',2015,'Josh Brolin','Thanos','Thanos')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (14,'Ant-Man',2015,'Chris Evans','Steve Rogers / Captain America','Steve Rogers / Captain America')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (14,'Ant-Man',2015,'Anthony Mackie','Sam Wilson / Falcon','Sam Wilson / Falcon')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (15,'Jessica Jones',2015,'Carrie-Anne Moss','Jeri Hogarth','Jeri Hogarth')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (15,'Jessica Jones',2015,'Mike Colter','Luke Cage','Luke Cage')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (15,'Jessica Jones',2015,'Rosario Dawson','Claire Temple','Claire Temple')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (16,'Captain America: Civil War',2016,'William Hurt','Secretary of State Thaddeus Ross','Secretary of State Thaddeus Ross')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (16,'Captain America: Civil War',2016,'Martin Freeman','Everett K. Ross','Everett K. Ross')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (16,'Captain America: Civil War',2016,'Marisa Tomei','May Parker','May Parker')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (16,'Captain America: Civil War',2016,'John Kani','King T''Chaka','King T''Chaka')

INSERT INTO [dbo].[staging] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (16,'Captain America: Civil War',2016,'John Slattery','Howard Stark','Howard Stark')
*/

INSERT INTO [dbo].[staging-hp] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (5,'The Avengers: Os Vingadores',2012,'Josh Brolin','Thanos','Thanos')

INSERT INTO [dbo].[staging-hp] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (17,'Doutor Estranho',2016,'Rachel McAdams','Clea?','Clea?')

INSERT INTO [dbo].[staging-hp] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (17,'Doutor Estranho',2016,'Mads Mikkelsen','Dormammu?','Dormammu?')

INSERT INTO [dbo].[staging-hp] ([order],[movie],[year],[actor],[character],[character_n])
     VALUES (14,'Homem-Formiga',2015,'Stan Lee','Stan Lee','Stan Lee')

--=============================
--normalize characters

update [staging-hp] set character_n = character where 1=1

update [staging-hp] set character_n = 'Sam Wilson / Falcon'
where actor = 'Anthony Mackie'

update [staging-hp] set character_n = 'Scott Lang / Ant-Man'
where actor = 'Paul Rudd'

update [staging-hp] set character_n = 'Wanda Maximoff / Scarlet Witch'
where actor = 'Elizabeth Olsen'

update [staging-hp] set character_n = 'Agent Coulson'
where actor = 'Clark Gregg'

update [staging-hp] set character_n = 'Bucky Barnes / Winter Soldier'
where actor = 'Sebastian Stan'

update [staging-hp] set character_n = 'Bruce Banner / Hulk'
where actor = 'Mark Ruffalo' or actor = 'Lou Ferrigno' or actor = 'Edward Norton'

update [staging-hp] set character_n = 'James Rhodes / War Machine'
where actor = 'Terrence Howard' or actor = 'Don Cheadle'

update [staging-hp] set character_n = 'Jarvis / Vision'
where actor = 'Paul Bettany'

update [staging-hp] set character_n = 'Happy Hogan'
where actor = 'Jon Favreau'

update [staging-hp] set character_n = 'Tony Stark / Iron Man'
where actor = 'Robert Downey Jr.'

update [staging-hp] set character_n = 'Natasha Romanoff / Black Widow'
where actor = 'Scarlett Johansson'

update [staging-hp] set character_n = 'Steve Rogers / Captain America'
where actor = 'Chris Evans'

update [staging-hp] set character_n = 'Clint Barton / Hawkeye'
where actor = 'Jeremy Renner'

update [staging-hp] set character_n = 'Bucky Barnes / Winter Soldier'
where actor = 'Sebastian Stan'

update [staging-hp] set character_n = 'Timothy ''Dum Dum'' Dugan'
where actor = 'Neal McDonough'

update [staging-hp] set character_n = 'Dormammu?'
where actor = 'Mads Mikkelsen'

update [staging-hp] set character_n = 'Clea?'
where actor = 'Rachel McAdams'

update [staging-hp] set character_n = 'Hope van Dyne / Vasp?'
where actor = 'Evangeline Lilly'

update [staging-hp] set character_n = '?'
where character_n = ''

update [staging-hp] set character_n = 'Stan Lee'
where actor = 'Stan Lee'

update [staging-hp] set character_n = 'Baron Wolfgang von Strucker'
where actor = 'Thomas Kretschmann'

update [staging-hp] set character_n = 'F.R.I.D.A.Y.'
where actor = 'Kerry Condon'

update [staging-hp] set character_n = 'Lady Sif'
where actor = 'Jaimie Alexander'

update [staging-hp] set character_n = 'Erik Selvig'
where actor = 'Stellan Skarsgård'

update [staging-hp] set character_n = 'Pietro Maximoff / Quicksilver'
where actor = 'Aaron Taylor-Johnson'

update [staging-hp] set character_n = 'Agent Maria Hill'
where actor = 'Cobie Smulders'

update [staging-hp] set character_n = 'Agent Sharon Carter'
where actor = 'Emily VanCamp'

update [staging-hp] set character_n = 'Ho Yinsen'
where actor = 'Shaun Toub'

update [staging-hp] set character_n = 'Sitwell'
where actor = 'Maximiliano Hernández'

update [staging-hp] set character_n = 'General ''Thunderbolt'' Ross'
where actor = 'William Hurt'

update [staging-hp] set character_n = 'D.A. Samantha Reyes'
where actor = 'Michelle Hurd'

update [staging-hp] set character_n = 'Agent Carter'
where actor = 'Hayley Atwell'

update [staging-hp] set character_n = 'Agent Melinda May'
where actor = 'Ming-Na Wen'

update [staging-hp] set character_n = 'Dr. Hank Pym / Ant-Man'
where actor = 'Michael Douglas'

update [staging-hp] set character_n = 'Janet Van Dyne / Vasp'
where actor = 'Hayley Lovitt'

update [staging-hp] set character_n = 'Ivan Vanko / Whiplash'
where actor = 'Mickey Rourke'

update [staging-hp] set character_n = 'Peter Parker / Spider-Man'
where actor = 'Tom Holland'

update [staging-hp] set character_n = 'Obadiah Stane / Iron Monk'
where actor = 'Jeff Bridges'

update [staging-hp] set character_n = 'Johann Schmidt / Red Skull'
where actor = 'Hugo Weaving'

update [staging-hp] set character_n = 'Matt Murdock / Daredevil'
where actor = 'Charlie Cox'

--=============================
--normalize data

update [staging-hp] set movie = 'Capitão América: O Soldado Invernal'
where movie = 'Capitão América 2: O Soldado Invernal'

update [staging-hp] set character_n = 'Adolph Hitler'
where character in ('''Adolph Hitler''')







