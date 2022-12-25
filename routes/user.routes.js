const Router = require('express')
const router = new Router()
const flash = require("express-flash")
const session = require("express-session")
const passport = require("passport")


const initializePassport = require('../passportConfigure')
initializePassport(passport)

const { getHome,
    getLogin,
    getDatabase,
    getLogout,
    postDatabase,
    getCreate,
    postCreate,
    getCreateEmployee,
    postCreateEmployee,
    getCreateReport,
    postCreateReport,
    getRoles,
    postRoles,
} = require('../controller/user.controller')


router.use(
    session({
        secret: 'secret',

        resave: false,

        saveUninitialized: false
    })
)

router.use(passport.initialize())
router.use(passport.session())


router.use(flash())

//Маршруты, по которым отправляются запросы
router.get('/', getHome)
router.get("/users/login", checkAuthenticated, getLogin)
router.get('/users/dashboard', checkNotAuthenticated, getDatabase) // , getDatabase
router.get("/users/logout", getLogout)
router.post("/users/dashboard/:id", postDatabase)
router.get("/createPolicy", getCreate)
router.post("/createPolicy", postCreate)
router.get("/employee", getCreateEmployee)
router.post("/employee", postCreateEmployee)
router.get("/report", getCreateReport)
router.post("/report", postCreateReport)
router.get("/users/roles", getRoles)
router.post("/users/roles", postRoles)
router.post(
    "/users/login", // () => res.redirect("/users/dashboard")
    passport.authenticate("local", {
        successRedirect: "/users/dashboard",
        failureRedirect: "/users/login", //"/users/login",
        failureFlash: true
    })
);

function checkAuthenticated(req, res, next) {
    if (req.isAuthenticated()) {
        return res.redirect("/users/dashboard");
    }
    next();
}

function checkNotAuthenticated(req, res, next) {
    if (req.isAuthenticated()) {
        return next();
    }
    res.redirect("/users/login");
}

module.exports = router