// routes/userRoutes.js
import express from 'express';
import {
    getAllUsers,
    getUserById,
    getSellers,
    getCustomers,
    getPendingMarkets,
    createUser,
    updateUser,
    deleteUser
} from '../controllers/userController.js';

const router = express.Router();

// GET routes
router.get('/', getAllUsers);
router.get('/sellers', getSellers);
router.get('/customers', getCustomers);
router.get('/pending-markets', getPendingMarkets);
router.get('/:id', getUserById);

// POST routes
router.post('/', createUser);

// PUT routes
router.put('/:id', updateUser);

// DELETE routes
router.delete('/:id', deleteUser);

export default router;