// routes/authRoutes.js
import express from "express";
import {
    register,
    login,
    getCurrentUser,
    updateProfile,
    changePassword,
} from "../controllers/authController.js";

const router = express.Router();

// Auth routes
router.post("/signup", register);
router.post("/signin", login);
router.post("/register", register); // alias
router.post("/login", login); // alias

// User routes
router.get("/user/:userId", getCurrentUser);
router.put("/user/:userId", updateProfile);
router.put("/user/:userId/password", changePassword);

export default router;