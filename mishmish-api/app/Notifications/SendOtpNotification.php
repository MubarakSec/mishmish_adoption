<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class SendOtpNotification extends Notification
{
    use Queueable;

    public string $otp;

    /**
     * Create a new notification instance.
     */
    public function __construct(string $otp)
    {
        $this->otp = $otp;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('رمز التحقق لاستعادة كلمة المرور - تطبيق مشمش')
            ->greeting('مرحباً بك في مشمش!')
            ->line('لقد تلقينا طلباً لإعادة تعيين كلمة المرور لحسابك.')
            ->line('Your verification code is: ' . $this->otp)
            ->line('رمز التحقق الخاص بك هو: ' . $this->otp)
            ->line('هذا الرمز صالح لمدة 15 دقيقة فقط.')
            ->salutation('مع تحيات فريق تطبيق مشمش');
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            'otp' => $this->otp,
        ];
    }
}

