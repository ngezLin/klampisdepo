import api from "./api.service";

export const getDashboard = () => {
  return api.get("/dashboard");
};
