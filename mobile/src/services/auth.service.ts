import api from "./api.service";

export const login = (username: string, password: string) => {
  return api.post("/login/", {
    username,
    password,
  });
};
