<?php

namespace Database\Seeders;

use App\Models\Kitten;
use Illuminate\Database\Seeder;

class KittenSeeder extends Seeder
{
    public function run(): void
    {
        $kittens = [
            ['name' => 'مشمش', 'breed' => 'شيرازي', 'age' => '3 شهور', 'description' => 'مشمش قط صغير ودود يحب اللعب والحب. لونه برتقالي جميل وعيناه زرقاوان.', 'price' => 150.00, 'image_url' => 'https://placekitten.com/400/400'],
            ['name' => 'توتي', 'breed' => 'هندي قصير الشعر', 'age' => '4 شهور', 'description' => 'توتي قطة صغيرة لطيفة تحب النوم على الأرائك. هادئة ومرنة.', 'price' => 200.00, 'image_url' => 'https://placekitten.com/401/401'],
            ['name' => 'شوكو', 'breed' => 'セキジ', 'age' => '5 شهور', 'description' => 'شوكو قط أسود أنيق بعينين خضراوين. ذكي ومحب.', 'price' => 250.00, 'image_url' => 'https://placekitten.com/402/402'],
            ['name' => 'لولو', 'breed' => 'برتقالي', 'age' => '2 شهور', 'description' => 'لولو أصغر قط في المجموعة. تحتاج رعاية خاصة وحب كثير.', 'price' => 120.00, 'image_url' => 'https://placekitten.com/403/403'],
            ['name' => 'بسبوس', 'breed' => 'منزلي', 'age' => '6 شهور', 'description' => 'بسبوس قط أبيض بنقط سوداء. يحب الصيد ولا يحب الهدوء.', 'price' => 100.00, 'image_url' => 'https://placekitten.com/404/404'],
            ['name' => 'نورة', 'breed' => 'شيرازي', 'age' => '3 شهور', 'description' => 'نورة قطة بيضاء ناعمة كحرير. تحب أن تُداعب.', 'price' => 180.00, 'image_url' => 'https://placekitten.com/405/405'],
            ['name' => 'زيز', 'breed' => 'منزلي', 'age' => '4 شهور', 'description' => 'زيز قط صغير يحب القفز واللعب بالكرات.', 'price' => 160.00, 'image_url' => 'https://placekitten.com/406/406'],
            ['name' => 'فلة', 'breed' => 'شرقي', 'age' => '7 شهور', 'description' => 'فلة قطة نشيطة وذكية. تحب التسلق والاستكشاف.', 'price' => 220.00, 'image_url' => 'https://placekitten.com/407/407'],
            ['name' => 'مسك', 'breed' => 'مينيكوون', 'age' => '5 شهور', 'description' => 'مسك قط به ثلاث ألوان. هادئ ومطيع وأنيق.', 'price' => 300.00, 'image_url' => 'https://placekitten.com/408/408'],
            ['name' => 'جوجو', 'breed' => 'بلو', 'age' => '6 شهور', 'description' => 'جوجو قط رمادي أنيق بعينين كبار. هادئ ومحب.', 'price' => 280.00, 'image_url' => 'https://placekitten.com/409/409'],
            ['name' => 'بلاك', 'breed' => 'أسود', 'age' => '3 شهور', 'description' => 'بلاك قط أسود صغير يحب النوم في الصناديق.', 'price' => 130.00, 'image_url' => 'https://placekitten.com/410/410'],
            ['name' => 'سكر', 'breed' => 'منزلي', 'age' => '2 شهور', 'description' => 'سكر قط صغير مضحك بعينين كبيرتين يحب اللعب.', 'price' => 80.00, 'image_url' => 'https://placekitten.com/411/411'],
        ];

        foreach ($kittens as $kitten) {
            Kitten::create($kitten);
        }
    }
}
