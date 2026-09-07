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
                'breed' => 'شيرازي',
                'age' => '3 شهور',
                'description' => 'مشمش قط صغير ودود يحب اللعب والمرح. لونه برتقالي مشمشي جميل وعيناه عسليتان تملؤهما البهجة.',
                'price' => 150.00,
                'image_url' => 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=600&auto=format&fit=crop&q=80',
            ],
            [
                'name' => 'توتي',
                'breed' => 'شيرازي ناصع',
                'age' => '4 شهور',
                'description' => 'توتي قطة صغيرة لطيفة هادئة تحب النوم في الأماكن الدافئة، مطعمة ونظيفة جداً.',
                'price' => 200.00,
                'image_url' => 'https://images.unsplash.com/photo-1573865526739-10659fec78a5?w=600&auto=format&fit=crop&q=80',
            ],
            [
                'name' => 'شوكو',
                'breed' => 'بريطاني قصير الشعر',
                'age' => '5 شهور',
                'description' => 'شوكو قط رائع بعينين خضراوين ولمعان فريد، يتمتع بشخصية ذكية ومحبة للأطفال.',
                'price' => 250.00,
                'image_url' => 'https://images.unsplash.com/photo-1533738363-b7f9aef128ce?w=600&auto=format&fit=crop&q=80',
            ],
            [
                'name' => 'لولو',
                'breed' => 'إسكتلندي مطوي الأذن',
                'age' => '2 شهور',
                'description' => 'لولو أصغر قطة في المجموعة، لطيفة وحنونة للغاية وتحب الجلوس بالقرب منك دائماً.',
                'price' => 180.00,
                'image_url' => 'https://images.unsplash.com/photo-1592194996308-7b43878e84a6?w=600&auto=format&fit=crop&q=80',
            ],
            [
                'name' => 'بسبوس',
                'breed' => 'تابي مخطط',
                'age' => '6 شهور',
                'description' => 'بسبوس قط أليف نشيط ومحب للاستكشاف والقفز، متعلم على صندوق الفضلات.',
                'price' => 120.00,
                'image_url' => 'https://images.unsplash.com/photo-1561948955-570b270e7c36?w=600&auto=format&fit=crop&q=80',
            ],
            [
                'name' => 'نورة',
                'breed' => 'أنغورا تركي',
                'age' => '3 شهور',
                'description' => 'نورة قطة بيضاء ناعمة كالحرير بعيون واسعة، تحب المداعبة والألعاب الخفيفة.',
                'price' => 210.00,
                'image_url' => 'https://images.unsplash.com/photo-1543852786-1cf6624b9987?w=600&auto=format&fit=crop&q=80',
            ],
            [
                'name' => 'زيزو',
                'breed' => 'أمريكي قصير الشعر',
                'age' => '4 شهور',
                'description' => 'زيزو قط صغير رشيق يحب اللعب بالكرات والركض في أرجاء المنزل بحيوية ومرح.',
                'price' => 160.00,
                'image_url' => 'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=600&auto=format&fit=crop&q=80',
            ],
            [
                'name' => 'فلة',
                'breed' => 'سيامي أصيل',
                'age' => '7 شهور',
                'description' => 'فلة قطة سيامية أنيقة ذات حضور لافت، فضولية وذكية وتتعلم الحركات بسرعة.',
                'price' => 240.00,
                'image_url' => 'https://images.unsplash.com/photo-1513360309081-38f076278f94?w=600&auto=format&fit=crop&q=80',
            ],
            [
                'name' => 'مسك',
                'breed' => 'ماين كون',
                'age' => '5 شهور',
                'description' => 'مسك يتمتع بفرو كثيف فاخر وملامح ملكية، هادئ ومطيع ويحب الاسترخاء.',
                'price' => 320.00,
                'image_url' => 'https://images.unsplash.com/photo-1535930891776-0c2dfb7fda1a?w=600&auto=format&fit=crop&q=80',
            ],
            [
                'name' => 'جوجو',
                'breed' => 'روسي أزرق',
                'age' => '6 شهور',
                'description' => 'جوجو قط رمادي مميز وفرو مخملي، هادئ ولا يصدر صوتاً ومناسب جداً للشقق السكنية.',
                'price' => 290.00,
                'image_url' => 'https://images.unsplash.com/photo-1548802673-380ab8ebc7b7?w=600&auto=format&fit=crop&q=80',
            ],
            [
                'name' => 'بلاك',
                'breed' => 'بومباي أسود',
                'age' => '3 شهور',
                'description' => 'بلاك قط أسود لماع كالفهد الصغير، خفيف الظل وودود للغاية ويحب النوم بالقرب منك.',
                'price' => 140.00,
                'image_url' => 'https://images.unsplash.com/photo-1508932999334-707924217f0b?w=600&auto=format&fit=crop&q=80',
            ],
            [
                'name' => 'سكر',
                'breed' => 'هيمالايا',
                'age' => '2 شهور',
                'description' => 'سكر كتلة من اللطافة، يجمع بين هدوء الشيرازي وألوان السيامي الجذابة.',
                'price' => 190.00,
                'image_url' => 'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=600&auto=format&fit=crop&q=80',
            ],
        ];

        foreach ($kittens as $kitten) {
            Kitten::create($kitten);
        }
    }
}
