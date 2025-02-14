import express from 'express';
import mongoose from 'mongoose';
import { mongoUri } from './database.js';
import { PORT } from './config/config.js';
import bookRoutes from './routes/bookRoute.js';
import cors from 'cors';

const app = express();

app.use(express.json());

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type']
}));

app.get('/', (request, response) => {
  console.log(request);
  return response.status(234).send("Welcome to Book Store");
});

app.use('/books', bookRoutes);

mongoose.connect(mongoUri).then(() => {
  app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
  });
}).catch(err => {
  console.log("Error while connecting to the database", err);
});
