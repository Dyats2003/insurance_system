const Pool = require("pg").Pool;

const pool = new Pool({
    user: 'postgres',
    password: 'Dyats20032003dydy',
    host: 'localhost',
    port: 5432,
    database: 'insurance'
});
pool.connect()

module.exports = pool;