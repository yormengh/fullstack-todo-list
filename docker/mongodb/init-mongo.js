// docker/mongodb/init-mongo.js
db.createUser({
  user: process.env.MONGO_INITDB_ROOT_USERNAME || 'admin',
  pwd: process.env.MONGO_INITDB_ROOT_PASSWORD || 'password',
  roles: [
    {
      role: 'readWrite',
      db: process.env.MONGO_INITDB_DATABASE || 'appdb'
    }
  ]
});

// Create application database
db = db.getSiblingDB(process.env.MONGO_INITDB_DATABASE || 'appdb');

// Create sample collections if needed
db.createCollection('users');
db.createCollection('products');

print('Database initialized successfully');