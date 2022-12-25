const LocalStrategy = require('passport-local').Strategy
const pool = require('./databaseConfigure')

function initialize(passport) {
    const authenticateUser = (login, password, done) => {
        pool.query
        (
            `SELECT * FROM "user" WHERE login = $1`, [login],
            (err, results) => {
                if (err) {
                    console.log(err.message);
                    throw err
                }
                console.log(results.rows)

                if (results.rows.length > 0) {
                    const user = results.rows[0]
                    pool.query(
                        `SELECT * FROM "user" WHERE (SELECT (password = crypt($1, password)) AS pswmatch FROM "user" WHERE login = $2);`,
                        [password, login],
                        (e, r) => {
                            if (e) {
                                console.log(e.message);
                                throw e;
                            }

                            if (r.rowCount>0)
                                pool.query('set role $1', [user.role], () => {
                                    return done(null, user);
                                });
                            else {
                                return done(null, false, {message: "Пароль некорректен"});
                            }
                        }
                    )
                } else {
                    return done(null, false, {message: "Email незарегистрирован"})
                }
            }
        )
    }
    passport.use(
        new LocalStrategy(
            { usernameField: "login", passwordField: "password" },
            authenticateUser
        )
    );
    passport.serializeUser((user, done) => done(null, user.login));

    passport.deserializeUser((login, done) => {
        pool.query(`SELECT * FROM "user" WHERE login = $1`, [login], (err, results) => {
            if (err) {
                return done(err);
            }
            // console.log(`ID is ${results.rows[0].login}`);
            return done(null, results.rows[0]);
        });
    });
}

module.exports = initialize;