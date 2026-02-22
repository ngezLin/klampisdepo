import api from "./api";

export const userService = {
  // Get all users (admin only)
  getUsers: async () => {
    const res = await api.get("/users/");
    return res.data;
  },
};
