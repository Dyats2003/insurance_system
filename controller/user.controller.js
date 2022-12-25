const pool = require("../databaseConfigure");
const e = require("express");

let z = 0;
pool.query('SELECT * FROM "user"', (e, r)=>{
    z=r.rowCount+1;
})

//Работа непосредственно с запросами
const getHome = async (req, res) => {
    res.render("index")
}

const getLogin = async (req, res) => {
    res.render("login")
}

const getDatabase = async function (req, res) {
    const users = await pool.query("SELECT * FROM \"user\"")
    const policies = await pool.query('SELECT * FROM "policy"')
    const policy_types = await pool.query("SELECT * FROM policy_type")
    const employees = await pool.query("SELECT * FROM employee")
    const positions = await pool.query('SELECT * FROM "position"')
    const policy_holders = await pool.query("SELECT * FROM policy_holder")
    const drivers = await pool.query("SELECT * FROM driver")
    const driver_licenses = await pool.query("SELECT * FROM driver_license")
    const crvs = await pool.query("SELECT * FROM crv")
    const cars = await pool.query("SELECT * FROM car")
    const owners = await pool.query('SELECT * FROM "owner"')
    const carWithFinishingPolicies = await pool.query(`SELECT * FROM carswithfinishingpolicies`)
    const role = await pool.query(`SELECT login, "role" FROM "user" WHERE login=$1`,[req.user.login])

    res.render('dashboard', {
        users: users.rows,
        drivers: drivers.rows,
        policies: policies.rows,
        policy_types: policy_types.rows,
        employees: employees.rows,
        positions: positions.rows,
        policy_holders: policy_holders.rows,
        cars: cars.rows,
        owners: owners.rows,
        role: role.rows[0].role,
        user: req.user.login,
        carsWithEnding: carWithFinishingPolicies.rows
        //user: req.user.name
    });
}

const postDatabase = async function(req, res){
    const id = req.params.id;
    console.log(id)
    if (id > 0) {
        pool.query("call delete_policy_holder($1);", [+id], function(err, data) {
            if(err) return console.log(err);
            res.redirect("/users/dashboard");
        });
    }
    else {
        console.log(id);
        pool.query(`delete from "policy" where policy_id = $1;;`, [-(+id)], function(err, data) {
            if(err) return console.log(err);
            res.redirect("/users/dashboard");
        });
    }
    
}

const getCreate = async function(req, res){
    res.render("createPolicy");
}

const postCreate = function (req, res) {

    if(!req.body) return res.sendStatus(400);
    const issue_date = req.body.issue_date;
    const expire_date = req.body.expire_date;
    const sign_date = req.body.sign_date;
    const purpose = req.body.purpose;
    const has_trailer = req.body.has_trailer;
    let benefit = req.body.benefit;
    const is_approved = false;
    const owner_id = req.body.owner_id;
    const driver_id = req.body.driver_id;
    const policy_holder_id = req.body.policy_holder_id;
    const vin = req.body.vin;
    const policy_type_id = req.body.policy_type_id;
    const employee_id = req.body.employee_id;
    pool.query("INSERT INTO \"policy\" (issue_date, expire_date, sign_date, purpose, has_trailer, benefit, is_approved, owner_id, driver_id, policy_holder_id, vin, policy_type_id, employee_id) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)",
        [issue_date, expire_date, sign_date, purpose, has_trailer, benefit, is_approved,
            owner_id, driver_id, policy_holder_id, vin, policy_type_id, employee_id], function(err, data) {
        if(err){res.redirect("/users/dashboard");
            return console.log(err);
        }
        res.redirect("/users/dashboard")
    });
}
const getCreateEmployee = async function(req, res){
    res.render("employee.ejs");
}
const postCreateEmployee = function (req, res) {

    if(!req.body) return res.sendStatus(400);
    const employee_id=z;
    const full_name = req.body.full_name;
    const passport = req.body.passport;
    const phone_number = req.body.phone_number;
    const email = req.body.email;
    const position_id = req.body.position_id;
    const login = req.body.login;
    const password = req.body.password;
    const role = req.body.role;
    pool.query("INSERT INTO employee (full_name, passport, phone_number, email, position_id) VALUES ($1,$2,$3,$4,$5);",
        [full_name, passport, phone_number, email, position_id], function(err, data) {
            if(err) return console.log(err);
        });

    pool.query('INSERT INTO \"user\" (login, password, role, employee_id) VALUES ($1, $2, $3, $4);', [login, password, role, employee_id], function(err, data) {
        if(err) return console.log(err);
        res.redirect("/users/dashboard");
    });
}

const getCreateReport = async function(req, res){
    res.render("report.ejs");
}
const postCreateReport = function (req, res) {

    if(!req.body) return res.sendStatus(400);
    const employee_id = req.body.employee_id;
    const start_date=req.body.start_date;
    const end_date=req.body.end_date;
    const path=req.body.path;
    pool.query('CALL save_to_csv($1, $2, $3, $4);', [employee_id, start_date, end_date, path], function(err, data) {
        if(err) return console.log(err);
        res.redirect("/users/dashboard");
    });
}
const postRoles = async (req,res)=>{
    if(!req.body) return res.sendStatus(400);

    const id = req.body.id;
    const role = req.body.role;
    console.log(id, role)
    pool.query("UPDATE user_role SET role=$1 WHERE user_id=$2", [role, id], function(err, data) {
        if(err) return console.log(err);
        res.redirect("/users/dashboard");
    });
}
const postDelete = async (req,res)=>{
    const policy_id = req.params.policy_id;
    
}

const getLogout = async (req, res) => {
    req.logout(true, (e) => { if (e) throw e; });
    req.flash('success_msg',"Вы разлогинились")
    res.redirect("/users/login")
}

const getRoles = async (req,res) => {
    res.render("roles.ejs");
}


module.exports = {
    getHome,
    getLogin,
    getDatabase,
    getLogout,
    postDatabase,
    getCreate,
    postCreate,
    getCreateEmployee,
    postCreateEmployee,
    getRoles,
    postRoles,
    postDelete,
    getCreateReport,
    postCreateReport
}