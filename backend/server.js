require("dotenv").config();

const express=require("express");
const mysql=require("mysql2/promise");
const cors=require("cors");

const app=express();

app.use(cors());
app.use(express.json());

let db;

async function connectDB(){

db=await mysql.createPool({
host:process.env.DB_HOST||"localhost",
port:process.env.DB_PORT||3306,
user:process.env.DB_USER||"estate_user",
password:process.env.DB_PASSWORD||"estate_password",
database:process.env.DB_NAME||"estateflow"
});

console.log("✅ MySQL Connected");

}

async function connectWithRetry() {
  try {
    await connectDB();
  } catch (err) {
    console.error("⏳ DB not ready, retrying in 5 seconds...");
    setTimeout(connectWithRetry, 5000);
  }
}

connectWithRetry();



app.get("/api/properties",async(req,res)=>{
const [rows]=await db.query(
"SELECT * FROM properties"
);

res.json(rows);
});


// 🏥 Health Check Endpoint
app.get("/api/health",async(req,res)=>{
try{
const connection=await db.getConnection();
connection.release();
res.json({status:"healthy",timestamp:new Date().toISOString()});
}catch(err){
res.status(503).json({status:"unhealthy",error:err.message});
}
});



app.get("/api/properties/:id",async(req,res)=>{

const [rows]=await db.query(
"SELECT * FROM properties WHERE id=?",
[req.params.id]
);

res.json(rows[0]);

});



app.post("/api/bookmark",async(req,res)=>{

const {userId,propertyId}=req.body;

await db.query(
"INSERT INTO bookmarks(user_id,property_id) VALUES (?,?)",
[userId,propertyId]
);

res.json({
message:"Bookmarked"
});

});



app.get("/api/bookmarks/:userId",async(req,res)=>{

const [rows]=await db.query(`
SELECT p.*
FROM bookmarks b
JOIN properties p
ON p.id=b.property_id
WHERE b.user_id=?
`,[req.params.userId]);

res.json(rows);

});



app.delete("/api/bookmark/:userId/:propertyId",async(req,res)=>{

await db.query(
"DELETE FROM bookmarks WHERE user_id=? AND property_id=?",
[
req.params.userId,
req.params.propertyId
]
);

res.json({
message:"Removed"
});

});



app.post("/api/contact",async(req,res)=>{

const {userId,propertyId}=req.body;

await db.query(
"INSERT INTO contacts(user_id,property_id) VALUES (?,?)",
[userId,propertyId]
);

res.json({
message:"Contact recorded"
});

});



app.post("/api/purchase",async(req,res)=>{

const {userId,propertyId}=req.body;

await db.query(
"INSERT INTO purchases(user_id,property_id) VALUES (?,?)",
[userId,propertyId]
);

res.json({
message:"Purchase recorded"
});

});



app.get("/api/dashboard/:userId",async(req,res)=>{

let user=req.params.userId;

const [saved]=await db.query(
"SELECT COUNT(*) count FROM bookmarks WHERE user_id=?",
[user]
);

const [contacted]=await db.query(
"SELECT COUNT(*) count FROM contacts WHERE user_id=?",
[user]
);

const [purchased]=await db.query(
"SELECT COUNT(*) count FROM purchases WHERE user_id=?",
[user]
);

res.json({
saved:saved[0].count,
contacted:contacted[0].count,
purchased:purchased[0].count
});

});



app.listen(process.env.PORT||5000,()=>{
console.log(`✅ Server Running on port ${process.env.PORT||5000}`);
});