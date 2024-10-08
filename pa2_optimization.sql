
-- non-optimised

explain analyze

select main_t.*, t2.student_q
from (
	select t.teacher_name, 
		t.teacher_surname, 
		t.teacher_id,
		count(sub.subject_id) as subject_q
	from teachers t
	right join subjects sub
	on sub.teacher_id = t.teacher_id
	group by 1, 2, 3
) as main_t
left join (
	select 
		sub.teacher_id,
		count(st.student_id) as student_q
	from students st
	left join subjects sub
	on sub.subject_id = st.subject_id
	group by 1) as t2
on main_t.teacher_id = t2.teacher_id
where subject_q = (
	select sq_t.subject_q
	from (
		select count(subject_id) as subject_q
		from subjects
		group by teacher_id
		order by subject_q desc
		limit 1)
	as sq_t )
			
-- -> Nested loop left join  (cost=10312 rows=0) (actual time=618..624 rows=8 loops=1)
    

	
-- optimized

create index idx_t_name_surname
on teachers (teacher_id, teacher_name, teacher_surname)

-- drop index idx_t_name_surname on teachers


explain analyze
	with count_st as (                           #num of students for every teacher
			select sub.teacher_id,
				count(st.student_id) as student_q
			from students st
			left join subjects sub
			on sub.subject_id = st.subject_id
			group by 1
		),
		
		count_sub as (				           	#num of subjects for every teacher
			select t.teacher_id,
				t.teacher_name, 
				t.teacher_surname,
				count(sub.subject_id) as subject_q
			from teachers t
			right join subjects sub
			on sub.teacher_id = t.teacher_id
			group by 1, 2, 3
		),
		
		c_sub_max as (				           #max num of subjects
			select max(subject_q) as sub_q_max
			from count_sub
		),
		
		main_t as (
			select count_sub.*,
				count_st.student_q
			from count_sub
			left join count_st
			on count_sub.teacher_id = count_st.teacher_id
			inner join c_sub_max
			on count_sub.subject_q = c_sub_max.sub_q_max
	
		)
		
	 select * from main_t
	
--  -> Nested loop left join  (cost=10312 rows=0) (actual time=282..286 rows=8 loops=1)
    