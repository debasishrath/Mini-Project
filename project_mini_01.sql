use ipl;
show tables;
select * from ipl_bidder_details;
select * from ipl_bidder_points;
select * from ipl_bidding_details;
select * from ipl_match;
select * from ipl_match_schedule;
select * from ipl_player;
select * from ipl_stadium;
select * from ipl_team;
select * from ipl_team_players;
select * from ipl_team_standings;
select * from ipl_tournament;
select * from ipl_user;

-- 1. Show the percentage of wins of each bidder in the order of highest to lowest percentage.

select bdr_dt.bidder_id 'Bidder ID', bdr_dt.bidder_name 'Bidder Name', 
(select count(*) from ipl_bidding_details bid_dt 
where bid_dt.bid_status = 'won' and bid_dt.bidder_id = bdr_dt.bidder_id) / 
(select no_of_bids from ipl_bidder_points bdr_pt 
where bdr_pt.bidder_id = bdr_dt.bidder_id)*100 as 'Percentage of Wins (%)'
from ipl_bidder_details bdr_dt order by 3 desc;

-- 2. Which teams have got the highest and the lowest no. of bids?

select team_id, team_name 'Team Name', count(*) 'Number of Bids' from ipl_team t join ipl_bidding_details bid_dt
on t.team_id = bid_dt.bid_team where bid_status <> 'cancelled' group by bid_team 
having count(*) = (select count(*) from ipl_bidding_details where bid_status <> 'cancelled' 
group by bid_team order by count(*) desc limit 1) or 
count(*) = (select count(*) from ipl_bidding_details where bid_status <> 'cancelled' 
group by bid_team order by count(*) limit 1);

-- 3. In a given stadium, what is the percentage of wins by a team which had won the toss?

select stadium_id 'Stadium ID', stadium_name 'Stadium Name',
(select count(*) from ipl_match m join ipl_match_schedule ms on m.match_id = ms.match_id
where ms.stadium_id = s.stadium_id and (toss_winner = match_winner)) /
(select count(*) from ipl_match_schedule ms where ms.stadium_id = s.stadium_id) * 100 
as 'Percentage of Wins by teams who won the toss (%)'
from ipl_stadium s;

-- 4. What is the total no. of bids placed on the team that has won highest no. of matches?

select team_id 'Team ID', team_name 'Team Name', count(*) 'Total Bids'
from ipl_bidding_details join ipl_team on team_id = bid_team 
where bid_status <> 'cancelled' group by bid_team
having bid_team = (select team_id from ipl_team_standings order by matches_won desc limit 1);

-- 5. From the current team standings, if a bidder places a bid on which of the teams, 
-- there is a possibility of (s)he winning the highest no. of points – in simple words, 
-- identify the team which has the highest jump in its total points (in terms of percentage) 
-- from the previous year to current year.

select t.team_id 'Team ID', t.team_name 'Team Name', 
((select total_points from ipl_team_standings ts where ts.team_id = t.team_id and tournmt_id = 2018) - 
(select total_points from ipl_team_standings ts where ts.team_id = t.team_id and tournmt_id = 2017) ) /
(select total_points from ipl_team_standings ts where ts.team_id = t.team_id and tournmt_id = 2017) * 100 
as 'Jump in total points from last year (%)'
from ipl_team t order by 3 desc limit 1;



-- 6.	Display total matches played, total matches won and total matches lost by team along with its team name.
select t.team_id,sum(ts.matches_played) as Total_matches_played,sum(ts.matches_won) as Total_matches_won,sum(ts.matches_lost) as Total_matches_lost,t.team_name
from ipl_team_standings ts inner join ipl_team t
on ts.team_id = t.team_id
group by team_name;

-- 7.	Display the bowlers for Mumbai Indians team.
select tp.player_id,p.player_name
from ipl_team t inner join ipl_team_players tp
on t.team_id = tp.team_id
inner join ipl_player p
on p.player_id =tp.player_id
where tp.player_role='Bowler' and t.team_name='Mumbai Indians';
-- 8.	How many all-rounders are there in each team, Display the teams with more than 4 
   -- all-rounder in descending order.
   
   select t.team_id,t.team_name,tp.player_role,count(tp.player_role) as All_rounder_count
from ipl_team t inner join ipl_team_players tp
on t.team_id = tp.team_id
inner join ipl_player p 
on p.player_id =tp.player_id
where tp.player_role='All-Rounder'
group by t.team_name
having count(tp.player_role)>4
order by 4 desc;
