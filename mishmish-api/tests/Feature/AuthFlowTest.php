<?php

namespace Tests\Feature;

use App\Models\User;
use App\Notifications\SendOtpNotification;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Notification;
use Tests\TestCase;

class AuthFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register()
    {
        $response = $this->postJson('/api/register', [
            'name' => 'فهد',
            'email' => 'fahad@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure(['message', 'user', 'token']);

        $this->assertDatabaseHas('users', ['email' => 'fahad@example.com']);
    }

    public function test_user_can_login()
    {
        $user = User::create([
            'name' => 'سارة',
            'email' => 'sara@example.com',
            'password' => bcrypt('secret123'),
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'sara@example.com',
            'password' => 'secret123',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure(['message', 'user', 'token']);
    }

    public function test_forgot_password_sends_notification_with_numeric_otp()
    {
        Notification::fake();

        $user = User::create([
            'name' => 'علي',
            'email' => 'ali@example.com',
            'password' => bcrypt('oldpassword'),
        ]);

        $response = $this->postJson('/api/forgot-password', [
            'email' => 'ali@example.com',
        ]);

        $response->assertStatus(200);

        Notification::assertSentTo(
            $user,
            SendOtpNotification::class,
            function ($notification) {
                return strlen($notification->otp) === 6 && ctype_digit($notification->otp);
            }
        );

        $record = DB::table('password_reset_tokens')->where('email', 'ali@example.com')->first();
        $this->assertNotNull($record);

        // Verify OTP code
        $verifyResponse = $this->postJson('/api/verify-code', [
            'email' => 'ali@example.com',
            'code' => $record->token,
        ]);
        $verifyResponse->assertStatus(200);

        // Reset password
        $resetResponse = $this->postJson('/api/reset-password', [
            'email' => 'ali@example.com',
            'password' => 'newpassword123',
            'password_confirmation' => 'newpassword123',
        ]);
        $resetResponse->assertStatus(200);

        // Login with new password
        $loginResponse = $this->postJson('/api/login', [
            'email' => 'ali@example.com',
            'password' => 'newpassword123',
        ]);
        $loginResponse->assertStatus(200);
    }
}
