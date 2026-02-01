-- Simulador de eventos para a tabela criada, nao usei o Faker pra poder facilitar o entendimento do processo todo (meu no caso)
-- Adicionado nomes CDC no final dos eventos novos e alterados para facilitar visualização no AKHQ

-- INSERTS – Novas atividades 

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
)
VALUES
    (90123, 'Corrida ao entardecer (CDC)',  'Run',     6300, 1850, '2025-12-02 18:05:00', NOW(), 'Strava App',            'strava'),
    (91357, 'Pedal treino (CDC)',           'Ride',   14500, 3200, '2025-12-03 07:10:00', NOW(), 'Garmin Forerunner 255', 'external_device'),
    (92468, 'Natação (CDC)',                'Swim',    1400, 1000, '2025-12-03 19:05:00', NOW(), 'Sem dispositivo',       'manual'),
    (93579, 'Musculação – CDC (CDC)',       'Training',   0, 2900, '2025-12-04 18:10:00', NOW(), 'Sem dispositivo',       'manual'),
    (94680, 'Corrida matinal (CDC)',        'Run',     4800, 1600, '2025-12-04 06:22:00', NOW(), 'Garmin Forerunner 255', 'external_device'),
    (95721, 'Pedal (CDC)',                  'Ride',   11200, 2100, '2025-12-06 17:45:00', NOW(), 'Strava App',            'strava'),
    (96842, 'Musculação  (CDC)',            'Training',   0, 2500, '2025-12-06 11:30:00', NOW(), 'Sem dispositivo',       'manual');


-- 2) UPDATES – Alteracao de atividades existentes

UPDATE strava_activities
    SET activity_distance = activity_distance + 300,
        activity_name       = 'Corrida pela manhã (CDC)',
        activity_updated_at = NOW()
    WHERE activity_id = 41236;

UPDATE strava_activities
    SET activity_distance    = activity_distance + 1000,
        activity_moving_time = activity_moving_time + 420,
        activity_name          = 'Pedal Subida da Serra (CDC)',
        activity_updated_at    = NOW()
    WHERE activity_id = 84567;

UPDATE strava_activities
    SET activity_distance = 2000,
        activity_name       = 'Natação noturna (CDC)',
        activity_updated_at = NOW()
    WHERE activity_id = 64570;

UPDATE strava_activities
    SET activity_moving_time = activity_moving_time + 900,
        activity_name           = 'Musculação (CDC)',
        activity_updated_at     = NOW()
    WHERE activity_id = 74590;


-- DELETES – Atividades excluidas

DELETE FROM strava_activities
    WHERE activity_id = 32498;

DELETE FROM strava_activities
    WHERE activity_id = 84567;

DELETE FROM strava_activities
    WHERE activity_id = 96842;