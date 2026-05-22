import express from "express";
import { getUsers, approveUser, rejectUser } from "../controllers/userController.js";

const router = express.Router();

router.get("/", getUsers);
router.patch("/:id/approve", approveUser);
router.patch("/:id/reject", rejectUser);

export default router;
