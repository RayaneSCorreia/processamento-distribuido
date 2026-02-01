-- Usado em caso de reprocessamentos para n dar erro no create
DROP TABLE IF EXISTS strava_activities;

CREATE TABLE strava_activities (
    activity_id      BIGINT PRIMARY KEY,
    activity_name             TEXT,
    activity_sport_type       TEXT, 
    activity_distance       NUMERIC,
    activity_moving_time    INT,
    activity_start_date       TIMESTAMP,
    activity_updated_at       TIMESTAMP,
    activity_device_name      TEXT,
    activity_entry_source     TEXT
);
-- Insert de 20 registros para adicionar dados inicais ao banco
INSERT INTO strava_activities (
    activity_id,
    activity_name,
    activity_sport_type, 
    activity_distance,
    activity_moving_time,
    activity_start_date,
    activity_updated_at,
    activity_device_name,
    activity_entry_source
) VALUES
    (21347, 'Corrida pela manhã',      'Run',      5200, 1750, '2025-07-03 06:12:00', '2025-07-03 07:05:00', 'Garmin Forerunner 255', 'external_device'),
    (29831, 'Pedal pela manhã',        'Ride',    18500, 3600, '2025-07-15 07:40:00', '2025-07-15 09:00:00', 'Garmin Forerunner 255', 'external_device'),
    (32498, 'Natação noturna',         'Swim',     1200,  900, '2025-07-28 18:20:00', '2025-07-28 19:00:00', 'Sem dispositivo',       'manual'),
    (35671, 'Corrida ao entardecer',   'Run',      6400, 1820, '2025-08-05 18:10:00', '2025-08-05 19:05:00', 'Strava App',            'strava'),
    (38902, 'Musculação',              'Training',    0, 2700, '2025-08-12 19:05:00', '2025-08-12 19:50:00', 'Sem dispositivo',       'manual'),
    (41236, 'Corrida noturna',         'Run',      8000, 2400, '2025-08-23 20:02:00', '2025-08-23 21:00:00', 'Garmin Forerunner 255', 'external_device'),
    (45789, 'Pedal Subida da Serra',   'Ride',    28000, 6000, '2025-09-03 05:55:00', '2025-09-03 08:40:00', 'Garmin Forerunner 255', 'external_device'),
    (48901, 'Natação ao entardecer',   'Swim',     1500, 1100, '2025-09-15 17:01:00', '2025-09-15 17:54:00', 'Garmin Forerunner 255', 'external_device'),
    (52347, 'Corrida pela manhã',      'Run',      7000, 2100, '2025-09-27 06:18:00', '2025-09-27 07:05:00', 'Strava App',            'strava'),
    (56781, 'Musculação',              'Training',    0, 1800, '2025-10-04 18:32:00', '2025-10-04 19:05:00', 'Sem dispositivo',       'manual'),
    (58934, 'Pedal noturno',           'Ride',    12000, 2400, '2025-10-11 20:15:00', '2025-10-11 21:05:00', 'Strava App',            'strava'),
    (61239, 'Corrida ao entardecer',   'Run',      5000, 1700, '2025-10-20 18:25:00', '2025-10-20 19:10:00', 'Garmin Forerunner 255', 'external_device'),
    (64570, 'Natação noturna',         'Swim',     1900, 1500, '2025-10-29 18:12:00', '2025-10-29 19:00:00', 'Sem dispositivo',       'manual'),
    (67812, 'Ciclismo Estrada Pacoti', 'Ride',    40000, 7200, '2025-11-05 05:35:00', '2025-11-05 09:10:00', 'Garmin Forerunner 255', 'external_device'),
    (70349, 'Musculação',              'Training',    0, 3000, '2025-11-12 18:18:00', '2025-11-12 19:18:00', 'Sem dispositivo',       'manual'),
    (74590, 'Corrida pela manhã',      'Run',      5100, 1650, '2025-11-18 06:03:00', '2025-11-18 06:52:00', 'Garmin Forerunner 255', 'external_device'),
    (78901, 'Corrida pela manhã',      'Run',     12000, 4300, '2025-11-23 05:40:00', '2025-11-23 07:15:00', 'Garmin Forerunner 255', 'external_device'),
    (81234, 'Pedal Curto 30min',       'Ride',     9000, 1800, '2025-11-27 12:02:00', '2025-11-27 12:42:00', 'Strava App',            'strava'),
    (84567, 'Natação',                 'Swim',     1000,  700, '2025-11-30 19:03:00', '2025-11-30 19:40:00', 'Sem dispositivo',       'manual'),
    (87903, 'Musculação',              'Training',    0, 3600, '2025-12-01 18:00:00', '2025-12-01 19:05:00', 'Sem dispositivo',       'manual');
