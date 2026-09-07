<?php

namespace Database\Seeders;

use App\Models\Kitten;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Schema;

class KittenSeeder extends Seeder
{
    public function run(): void
    {
        Schema::disableForeignKeyConstraints();
        Kitten::truncate();
        Schema::enableForeignKeyConstraints();

        $kittens = [
            [
                'name' => 'مشمش',
                'breed' => 'شيرازي برتقالي',
                'age' => '3 شهور',
                'description' => 'مشمش قط صغير ودود يحب اللعب والمرح. لونه برتقالي مشمشي جميل وعيناه عسليتان تملؤهما البهجة.',
                'price' => 150.00,
                'image_url' => '/images/cats/1_mishmish.jpg',
            ],
            [
                'name' => 'توتي',
                'breed' => 'شيرازي ناصع',
                'age' => '4 شهور',
                'description' => 'توتي قطة صغيرة لطيفة هادئة تحب النوم في الأماكن الدافئة، مطعمة ونظيفة جداً.',
                'price' => 200.00,
                'image_url' => '/images/cats/2_tooti.jpg',
            ],
            [
                'name' => 'شوكو',
                'breed' => 'بريطاني قصير الشعر',
                'age' => '5 شهور',
                'description' => 'شوكو قط رائع بلون بني كالشوكولاتة، يتمتع بشخصية ذكية ومحبة للأطفال.',
                'price' => 250.00,
                'image_url' => '/images/cats/3_choco.jpg',
            ],
            [
                'name' => 'لولو',
                'breed' => 'إسكتلندي مطوي الأذن',
                'age' => '2 شهور',
                'description' => 'لولو أصغر قطة في المجموعة، لطيفة وحنونة للغاية وتحب الجلوس بالقرب منك دائماً.',
                'price' => 180.00,
                'image_url' => '/images/cats/4_lulu.jpg',
            ],
            [
                'name' => 'بسبوس',
                'breed' => 'تابي مخطط',
                'age' => '6 شهور',
                'description' => 'بسبوس قط أليف نشيط ومحب للاستكشاف والقفز، متعلم على صندوق الفضلات.',
                'price' => 120.00,
                'image_url' => '/images/cats/5_basbous.jpg',
            ],
            [
                'name' => 'نورة',
                'breed' => 'أنغورا تركي',
                'age' => '3 شهور',
                'description' => 'نورة قطة بيضاء ناعمة كالحرير بعينين فريدتين (عسلي وأخضر زمردي)، تحب المداعبة.',
                'price' => 210.00,
                'image_url' => '/images/cats/6_noura.jpg',
            ],
            [
                'name' => 'زيزو',
                'breed' => 'أمريكي قصير الشعر',
                'age' => '4 شهور',
                'description' => 'زيزو قط صغير رشيق بنقشات فضية يحب اللعب بالكرات والركض في أرجاء المنزل بحيوية ومرح.',
                'price' => 160.00,
                'image_url' => '/images/cats/7_zezo.jpg',
            ],
            [
                'name' => 'فلة',
                'breed' => 'سيامي أصيل',
                'age' => '7 شهور',
                'description' => 'فلة قطة سيامية أنيقة ذات عيون زرقاء ياقوتية، فضولية وذكية وتتعلم الحركات بسرعة.',
                'price' => 240.00,
                'image_url' => '/images/cats/8_fella.jpg',
            ],
            [
                'name' => 'مسك',
                'breed' => 'ماين كون',
                'age' => '5 شهور',
                'description' => 'مسك يتمتع بفرو كثيف فاخر وملامح ملكية، هادئ ومطيع ويحب الاسترخاء.',
                'price' => 320.00,
                'image_url' => '/images/cats/9_mesk.jpg',
            ],
            [
                'name' => 'جوجو',
                'breed' => 'روسي أزرق',
                'age' => '6 شهور',
                'description' => 'جوجو قط رمادي مميز وفرو مخملي وعينين خضراوين، هادئ ولا يصدر صوتاً ومناسب جداً للشقق.',
                'price' => 290.00,
                'image_url' => '/images/cats/10_jojo.jpg',
            ],
            [
                'name' => 'بلاك',
                'breed' => 'بومباي أسود',
                'age' => '3 شهور',
                'description' => 'بلاك قط أسود لماع كالفهد الصغير بعيون ذهبية، خفيف الظل وودود للغاية ويحب النوم بالقرب منك.',
                'price' => 140.00,
                'image_url' => '/images/cats/11_black.jpg',
            ],
            [
                'name' => 'سكر',
                'breed' => 'هيمالايا',
                'age' => '2 شهور',
                'description' => 'سكر كتلة من اللطافة، يجمع بين نعومة الهيمالايا وألوان السيامي الجذابة.',
                'price' => 190.00,
                'image_url' => '/images/cats/12_sokar.jpg',
            ],
        ];

        foreach ($kittens as $kitten) {
            Kitten::create($kitten);
        }
    }
}
