const mysql = require('mysql2');
const express = require('express')
const app = express()
const port = 3000
const host= process.env.HOST
const user= process.env.USRNAME
const password= process.env.PASSWORD
const database= process.env.DATABASE

const connection = mysql.createConnection({
  host: host,
  user: user,
  password: password,
  database: database
});

connection.connect((err) => {
  if (err) throw err;
  console.log('Connected!');
});

app.get('/', (req, res) => {
    res.send(`Hello World! database creds ${user} -- ${password} -- ${database} -- ${host}`)
  })
  
  app.listen(port, () => {
    console.log(`${user} -- ${password} -- ${database} -- ${host}`)
    console.log(`Example app listening at http://localhost:${port}`)
  })