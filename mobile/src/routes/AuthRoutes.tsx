import { createNativeStackNavigator } from "@react-navigation/native-stack";
import LoginPage from "../pages/auth/LoginPage";

const Stack = createNativeStackNavigator();

export default function AuthRoutes() {
  return (
    <Stack.Navigator>
      <Stack.Screen
        name="Login"
        component={LoginPage}
        options={{ headerShown: false }}
      />
    </Stack.Navigator>
  );
}
