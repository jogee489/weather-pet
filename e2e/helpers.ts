/** Generates a minimal Open-Meteo forecast JSON response for use in tests. */
export function mockForecastResponse() {
  const now = new Date();
  const hourlyTimes = Array.from({ length: 25 }, (_, i) => {
    const d = new Date(now);
    d.setHours(d.getHours() + i, 0, 0, 0);
    return d.toISOString().slice(0, 16);
  });
  const dailyDates = Array.from({ length: 7 }, (_, i) => {
    const d = new Date(now);
    d.setDate(d.getDate() + i);
    return d.toISOString().slice(0, 10);
  });

  return {
    current: {
      temperature_2m: 18.5,
      apparent_temperature: 16.0,
      relative_humidity_2m: 72,
      weather_code: 2,
      wind_speed_10m: 15.0,
      is_day: 1,
    },
    hourly: {
      time: hourlyTimes,
      temperature_2m: Array(25).fill(18.0),
      weather_code: Array(25).fill(2),
    },
    daily: {
      time: dailyDates,
      weather_code: Array(7).fill(2),
      temperature_2m_max: Array(7).fill(22.0),
      temperature_2m_min: Array(7).fill(12.0),
    },
  };
}
