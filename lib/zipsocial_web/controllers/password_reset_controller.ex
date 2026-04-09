defmodule ZipsocialWeb.PasswordResetController do
  @moduledoc """
  Handles the email-OTP password-reset flow for regular users.

  GET  /password-reset            — form: enter email to request OTP
  POST /password-reset            — generate OTP, display it (simulates email)
  GET  /password-reset/:token     — form: enter OTP + new password
  POST /password-reset/:token     — validate OTP, update password
  """
  use ZipsocialWeb, :controller

  alias Zipsocial.Accounts

  # GET /password-reset
  def new(conn, _params) do
    render(conn, "new.html")
  end

  # POST /password-reset
  def create(conn, %{"reset" => %{"email" => email}}) do
    case Accounts.generate_password_reset_token(email) do
      {:ok, token, _user} ->
        # In production this token would be emailed. For now we display it
        # directly so the app is usable in development / demo environments.
        conn
        |> put_flash(:info, "Reset code generated. In a production environment this would be sent to #{email}. Your reset code is: #{token}")
        |> redirect(to: "/password-reset/#{token}")

      {:error, :not_found} ->
        # Don't reveal whether the email exists (security best-practice).
        conn
        |> put_flash(:info, "If that email is registered you'll receive a reset code shortly.")
        |> redirect(to: "/login")
    end
  end

  # GET /password-reset/:token
  def edit(conn, %{"token" => token}) do
    render(conn, "edit.html", token: token)
  end

  # POST /password-reset/:token
  def update(conn, %{"token" => token, "reset" => %{"password" => password, "password_confirmation" => confirmation}}) do
    case Accounts.reset_password(token, password, confirmation) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Password updated successfully. You can now log in.")
        |> redirect(to: "/login")

      {:error, :invalid_token} ->
        conn
        |> put_flash(:error, "Invalid reset code. Please request a new one.")
        |> redirect(to: "/password-reset")

      {:error, :expired_token} ->
        conn
        |> put_flash(:error, "Reset code has expired. Please request a new one.")
        |> redirect(to: "/password-reset")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Password could not be updated. Make sure it is at least 6 characters and both fields match.")
        |> render("edit.html", token: token)
    end
  end
end
