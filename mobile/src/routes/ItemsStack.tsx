import { createNativeStackNavigator } from "@react-navigation/native-stack";
import ItemsPage from "../pages/items/ItemsPage";
import ItemForm from "../pages/items/ItemForm";

const Stack = createNativeStackNavigator();

export default function ItemsStack() {
  return (
    <Stack.Navigator>
      <Stack.Screen
        name="ItemsList"
        component={ItemsPage}
        options={{ headerShown: false }}
      />
      <Stack.Screen
        name="ItemForm"
        component={ItemForm}
        options={{ title: "Item Form" }}
      />
    </Stack.Navigator>
  );
}
