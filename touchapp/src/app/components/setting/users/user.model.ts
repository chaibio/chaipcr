export interface UserModel {
  id: number | null,
  is_admin: boolean,
  name: string,
  email: string,
  password: string,
  confirm_password: string
}
