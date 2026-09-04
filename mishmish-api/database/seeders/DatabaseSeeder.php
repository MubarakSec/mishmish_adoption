<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        User::firstOrCreate(
            ['email' => 'user@mishmish.com'],
            [
                'name' => 'مستخدم تجريبي',
                'password' => Hash::make('123456'),
            ]
        );

        $this->call(KittenSeeder::class);
    }
}
