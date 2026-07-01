import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feelview/models/models.dart';
import 'package:feelview/services/auth_service.dart';

class SeedData {
  static const String sampleFamilyId = 'alvarez-family-001';

  static List<MemberModel> get sampleMembers => [
    MemberModel(
      id: 'member-rosa', familyId: sampleFamilyId, fullName: 'Rosa Alvarez', displayName: 'Grandma Rosa',
      role: UserRole.elder, relationshipLabelFromElder: const {}, isMinor: false,
      voicePronunciationHint: 'Rosa', treePosition: const TreePosition(generation: 0, order: 0),
      profilePhotoUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=400&q=80',
      isCoreCircleFor: ['member-rosa'], createdAt: DateTime.now(),
    ),
    MemberModel(
      id: 'member-carlos', familyId: sampleFamilyId, fullName: 'Carlos Alvarez', displayName: 'Carlos',
      role: UserRole.poster, relationshipLabelFromElder: {'member-rosa': 'your son'}, isMinor: false,
      voicePronunciationHint: 'Carlos', treePosition: const TreePosition(generation: 1, order: 0),
      profilePhotoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
      familyBranchLabel: 'Rosa\'s Children', isCoreCircleFor: ['member-rosa'], createdAt: DateTime.now(),
    ),
    MemberModel(
      id: 'member-elena', familyId: sampleFamilyId, fullName: 'Elena Garcia', displayName: 'Elena',
      role: UserRole.poster, relationshipLabelFromElder: {'member-rosa': 'your daughter'}, isMinor: false,
      voicePronunciationHint: 'Elena', treePosition: const TreePosition(generation: 1, order: 1),
      profilePhotoUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
      familyBranchLabel: 'Rosa\'s Children', isCoreCircleFor: ['member-rosa'], createdAt: DateTime.now(),
    ),
    MemberModel(
      id: 'member-david', familyId: sampleFamilyId, fullName: 'David Alvarez', displayName: 'David',
      role: UserRole.poster, relationshipLabelFromElder: {'member-rosa': 'your grandson'}, isMinor: false,
      voicePronunciationHint: 'David', treePosition: const TreePosition(generation: 2, order: 0),
      profilePhotoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
      familyBranchLabel: 'The Alvarez Branch', isCoreCircleFor: ['member-rosa'], createdAt: DateTime.now(),
    ),
    MemberModel(
      id: 'member-maria', familyId: sampleFamilyId, fullName: 'Maria Alvarez', displayName: 'Maria',
      role: UserRole.admin, relationshipLabelFromElder: {'member-rosa': 'your granddaughter'}, isMinor: false,
      voicePronunciationHint: 'Maria', treePosition: const TreePosition(generation: 2, order: 1),
      profilePhotoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
      familyBranchLabel: 'The Alvarez Branch', isCoreCircleFor: ['member-rosa'], createdAt: DateTime.now(),
    ),
    MemberModel(
      id: 'member-junior', familyId: sampleFamilyId, fullName: 'Junior Garcia', displayName: 'Junior',
      role: UserRole.poster, relationshipLabelFromElder: {'member-rosa': 'your grandson'}, isMinor: true,
      minorPermissionTier: MinorPermissionTier.supervised, guardianUserId: 'member-elena',
      voicePronunciationHint: 'Junior', treePosition: const TreePosition(generation: 2, order: 2),
      profilePhotoUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=400&q=80',
      familyBranchLabel: 'The Garcia Branch', isCoreCircleFor: ['member-rosa'], createdAt: DateTime.now(),
    ),
    MemberModel(
      id: 'member-jorge', familyId: sampleFamilyId, fullName: 'Jorge Alvarez', displayName: 'Uncle Jorge',
      role: UserRole.poster, relationshipLabelFromElder: {'member-rosa': 'your brother'}, isMinor: false,
      voicePronunciationHint: 'Jorge', treePosition: const TreePosition(generation: 0, order: 1),
      profilePhotoUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=400&q=80',
      familyBranchLabel: 'Extended Family', isCoreCircleFor: [], createdAt: DateTime.now(),
    ),
    MemberModel(
      id: 'member-sofia', familyId: sampleFamilyId, fullName: 'Sofia Alvarez', displayName: 'Aunt Sofia',
      role: UserRole.poster, relationshipLabelFromElder: {'member-rosa': 'your sister-in-law'}, isMinor: false,
      voicePronunciationHint: 'Sofia', treePosition: const TreePosition(generation: 0, order: 2),
      profilePhotoUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=400&q=80',
      familyBranchLabel: 'Extended Family', isCoreCircleFor: [], createdAt: DateTime.now(),
    ),
    MemberModel(
      id: 'member-mateo', familyId: sampleFamilyId, fullName: 'Mateo Garcia', displayName: 'Cousin Mateo',
      role: UserRole.poster, relationshipLabelFromElder: {'member-rosa': 'your nephew'}, isMinor: false,
      voicePronunciationHint: 'Mateo', treePosition: const TreePosition(generation: 1, order: 3),
      profilePhotoUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=400&q=80',
      familyBranchLabel: 'Extended Family', isCoreCircleFor: [], createdAt: DateTime.now(),
    ),
    MemberModel(
      id: 'member-leo', familyId: sampleFamilyId, fullName: 'Leo Alvarez', displayName: 'Little Leo',
      role: UserRole.poster, relationshipLabelFromElder: {'member-rosa': 'your great-grandson'}, isMinor: true,
      minorPermissionTier: MinorPermissionTier.supervised, guardianUserId: 'member-david',
      voicePronunciationHint: 'Leo', treePosition: const TreePosition(generation: 3, order: 0),
      profilePhotoUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=400&q=80',
      familyBranchLabel: 'The Great-Grandchildren', isCoreCircleFor: ['member-rosa'], createdAt: DateTime.now(),
    ),
  ];

  static List<PostModel> get samplePosts => [
    // ─── 1. David Alvarez (3 posts) ─────────────────────────────────────────
    PostModel(
      id: 'post-101', authorId: 'member-david', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Just graduated from college! So grateful for all your love and support, Grandma! We did it! 🎓',
      mediaUrl: 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Graduation Day',
      aiNarrationText: 'Here is a graduation photo from your grandson David. David is smiling in his black cap and gown holding his college diploma. David says: Just graduated from college! So grateful for all your love and support, Grandma!',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    PostModel(
      id: 'post-105', authorId: 'member-david', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Look how fast Little Leo can run now Grandma! He loves playing on the park swings! 🌳',
      mediaUrl: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Park Day',
      aiNarrationText: 'Here is a joyful photo shared by David of your great-grandson Little Leo. Little Leo is laughing while swinging high on the playground swings at the park.',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    PostModel(
      id: 'post-109', authorId: 'member-david', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Got promoted to Senior Analyst today at work! Couldn\'t be happier! Celebrating tonight with friends! 🎉',
      mediaUrl: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Job Promotion',
      aiNarrationText: 'Here is a photo from your grandson David celebrating his promotion to Senior Analyst at work. David is smiling proudly in a professional suit.',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),

    // ─── 2. Maria Alvarez (3 posts) ─────────────────────────────────────────
    PostModel(
      id: 'post-102', authorId: 'member-maria', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Happy Sunday everyone! Made your famous family recipe tamales today Grandma! They taste almost as good as yours! 🫔',
      mediaUrl: 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Sunday Dinner',
      aiNarrationText: 'Here is a kitchen photo from your granddaughter Maria. Maria shows a large plate of freshly steamed tamales on the dining table. Maria says: Happy Sunday everyone! Made your famous family recipe tamales today Grandma!',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PostModel(
      id: 'post-110', authorId: 'member-maria', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Finished my first 5k charity run this morning! Felt amazing crossing that finish line with my team! 🏃‍♀️',
      mediaUrl: 'https://images.unsplash.com/photo-1452626038306-9aae5e071dd3?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: '5K Charity Run',
      aiNarrationText: 'Here is a fitness photo from your granddaughter Maria after finishing her first 5k charity run. Maria is wearing a running bib and holding up her finisher medal with a big smile.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    PostModel(
      id: 'post-111', authorId: 'member-maria', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Finally finished decorating the living room in my new apartment! What do you think Grandma Rosa? 🏡',
      mediaUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'New Apartment',
      aiNarrationText: 'Here is an interior photo from your granddaughter Maria showing her newly decorated apartment living room with cozy pillows, plants, and sunlight coming through the window.',
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
    ),

    // ─── 3. Carlos Alvarez (3 posts) ────────────────────────────────────────
    PostModel(
      id: 'post-103', authorId: 'member-carlos', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Grilling up carne asada for Sunday barbecue! Wish you were here with us Mom! Sending big hugs! 🥩',
      mediaUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Family BBQ',
      aiNarrationText: 'Here is a barbecue photo from your son Carlos. Carlos is standing by the backyard grill cooking steaks and corn on the cob on a sunny afternoon. Carlos says: Grilling up carne asada for Sunday barbecue!',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PostModel(
      id: 'post-112', authorId: 'member-carlos', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Spent all afternoon in the garage restoring the engine on my classic 1968 Chevy! Running like a dream now! 🚗',
      mediaUrl: 'https://images.unsplash.com/photo-1517524008697-84bbe3c3fd98?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Car Restoration',
      aiNarrationText: 'Here is a garage photo from your son Carlos working on his vintage car engine. Carlos is smiling under the hood of his classic blue 1968 Chevy.',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    PostModel(
      id: 'post-113', authorId: 'member-carlos', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Great weekend fishing trip at Lake Tahoe! Caught a 5-pound bass right at sunrise! 🎣',
      mediaUrl: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Fishing Trip',
      aiNarrationText: 'Here is an outdoor photo from your son Carlos on a morning fishing boat at Lake Tahoe, holding up a large bass fish against a gorgeous sunrise.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),

    // ─── 4. Elena Garcia (3 posts) ──────────────────────────────────────────
    PostModel(
      id: 'post-104', authorId: 'member-elena', familyId: sampleFamilyId, type: PostType.video,
      caption: 'Planted the pink rose bushes you gave me Mom! They are blooming so beautifully in the garden this spring! 🌸',
      mediaUrl: 'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4',
      source: PostSource.native, occasion: 'Spring Garden',
      aiNarrationText: 'Here is a garden video from your daughter Elena. Elena shows bright pink rose bushes blooming in the springtime sunshine. Elena says: Planted the pink rose bushes you gave me Mom! They are blooming so beautifully!',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    PostModel(
      id: 'post-114', authorId: 'member-elena', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Enjoying my morning coffee and reading a good book on the patio while the birds sing! Peaceful Saturday! ☕',
      mediaUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Saturday Morning',
      aiNarrationText: 'Here is a relaxing photo from your daughter Elena showing a hot cup of coffee and an open book on her wooden garden patio table.',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    PostModel(
      id: 'post-115', authorId: 'member-elena', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Baking chocolate chip cookies from scratch with Junior after school! The kitchen smells wonderful! 🍪',
      mediaUrl: 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Baking Cookies',
      aiNarrationText: 'Here is a family photo from your daughter Elena and grandson Junior in the kitchen, taking a tray of golden brown chocolate chip cookies out of the oven.',
      createdAt: DateTime.now().subtract(const Duration(days: 11)),
    ),

    // ─── 5. Cousin Mateo (3 posts) ──────────────────────────────────────────
    PostModel(
      id: 'post-106', authorId: 'member-mateo', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Made it to the top of Yosemite Falls! Thinking of you Tia Rosa! The view is unbelievable! ⛰️',
      mediaUrl: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Hiking Trip',
      aiNarrationText: 'Here is a scenic hiking photo from your nephew Mateo. Mateo is standing on top of a mountain overlooking a breathtaking green valley and waterfall in Yosemite.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    PostModel(
      id: 'post-116', authorId: 'member-mateo', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Camping under a blanket of stars at Joshua Tree National Park! Campfire roasted marshmallows for desert! ⛺',
      mediaUrl: 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Camping Trip',
      aiNarrationText: 'Here is a nighttime camping photo from your nephew Mateo showing a glowing campfire and tent under a brilliant starry sky at Joshua Tree.',
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
    PostModel(
      id: 'post-117', authorId: 'member-mateo', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Meet the newest member of our family, our 8-week-old golden retriever puppy Buddy! He is so playful! 🐶',
      mediaUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'New Puppy',
      aiNarrationText: 'Here is an adorable pet photo from your nephew Mateo holding his new fluffy golden retriever puppy Buddy in his arms.',
      createdAt: DateTime.now().subtract(const Duration(days: 13)),
    ),

    // ─── 6. Junior Garcia (3 posts) ─────────────────────────────────────────
    PostModel(
      id: 'post-107', authorId: 'member-junior', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Scored two goals in my high school soccer game today! Coach said I was the MVP! ⚽',
      mediaUrl: 'https://images.unsplash.com/photo-1517649763962-0c623266ddc0?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Championship Game',
      aiNarrationText: 'Here is a sports photo from your grandson Junior. Junior is wearing his blue soccer jersey and holding a trophy after winning his game.',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    PostModel(
      id: 'post-118', authorId: 'member-junior', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Won 1st place at the Regional High School Science Fair with my AI robotic arm project! Hard work pays off! 🤖',
      mediaUrl: 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Science Fair',
      aiNarrationText: 'Here is an academic photo from your grandson Junior standing next to his award-winning robotic arm project with a blue first place ribbon at the science fair.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    PostModel(
      id: 'post-119', authorId: 'member-junior', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Played acoustic guitar on stage at our school spring talent show tonight! So much fun performing! 🎸',
      mediaUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Talent Show',
      aiNarrationText: 'Here is a musical photo from your grandson Junior playing an acoustic guitar under stage lights during his school talent show.',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),

    // ─── 7. Aunt Sofia (3 posts) ────────────────────────────────────────────
    PostModel(
      id: 'post-108', authorId: 'member-sofia', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Happy 60th Birthday to my wonderful husband Jorge! We raised a toast to you Rosa! 🎂',
      mediaUrl: 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Jorge\'s 60th Birthday',
      aiNarrationText: 'Here is a birthday celebration photo from your sister-in-law Aunt Sofia. Sofia and Uncle Jorge are smiling in front of a chocolate birthday cake surrounded by balloons.',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    PostModel(
      id: 'post-120', authorId: 'member-sofia', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Painted watercolor spring lilies in my weekend community art class today! Finding peace in creativity! 🎨',
      mediaUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Art Class',
      aiNarrationText: 'Here is an artistic photo shared by Aunt Sofia showing her vibrant watercolor painting of spring lily flowers on an art studio easel.',
      createdAt: DateTime.now().subtract(const Duration(days: 11)),
    ),
    PostModel(
      id: 'post-121', authorId: 'member-sofia', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Wonderful Sunday afternoon picnic with Jorge at the Botanical Gardens! The butterflies are everywhere! 🦋',
      mediaUrl: 'https://images.unsplash.com/photo-1526772662000-3f88f10405ff?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Botanical Picnic',
      aiNarrationText: 'Here is an outdoor photo from Aunt Sofia sitting on a checkered picnic blanket in lush green botanical gardens with colorful flower beds.',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),

    // ─── 8. Grandma Rosa (3 posts) ──────────────────────────────────────────
    PostModel(
      id: 'post-122', authorId: 'member-rosa', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Baking sweet pan dulce bread for our Sunday family gathering! Can\'t wait to hug all my grandchildren! ❤️',
      mediaUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Family Baking',
      aiNarrationText: 'Here is a warm photo from Grandma Rosa showing trays of freshly baked traditional sweet bread ready for Sunday dinner with the family.',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    PostModel(
      id: 'post-123', authorId: 'member-rosa', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Looking through my old family photo albums from when Carlos and Elena were little babies in 1985! Such blessed memories! 📖',
      mediaUrl: 'https://images.unsplash.com/photo-1544717302-de2939b7ef71?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Precious Memories',
      aiNarrationText: 'Here is a nostalgic photo from Grandma Rosa showing an open vintage photo album filled with cherished childhood pictures of Carlos and Elena.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    PostModel(
      id: 'post-124', authorId: 'member-rosa', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Watering my heirloom tomato and pepper plants in the backyard garden! Growing so tall and healthy this season! 🍅',
      mediaUrl: 'https://images.unsplash.com/photo-1592878904946-b3cd8ae243d0?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Rosa\'s Garden',
      aiNarrationText: 'Here is a garden photo from Grandma Rosa showing lush green tomato plants with bright red ripening tomatoes in her backyard garden.',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),

    // ─── 9. Uncle Jorge (3 posts) ───────────────────────────────────────────
    PostModel(
      id: 'post-125', authorId: 'member-jorge', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Thank you everyone for the heartfelt 60th birthday wishes! Feeling truly blessed to have such a wonderful family! 🎈',
      mediaUrl: 'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Birthday Thank You',
      aiNarrationText: 'Here is a celebration photo from Uncle Jorge holding up a glass of sparkling cider in gratitude for all the love on his 60th birthday.',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    PostModel(
      id: 'post-126', authorId: 'member-jorge', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Won our Sunday afternoon dominoes tournament against Carlos and Mateo! Still the undefeated champion! 🏆',
      mediaUrl: 'https://images.unsplash.com/photo-1611891487122-207579d67d98?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Dominoes Champion',
      aiNarrationText: 'Here is a fun game night photo from Uncle Jorge showing domino tiles lined up on the wooden table with a big smile.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    PostModel(
      id: 'post-127', authorId: 'member-jorge', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Enjoying a peaceful early morning walk around the lakeside trail! Crisp air and beautiful reflections on the water! 🌅',
      mediaUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Morning Walk',
      aiNarrationText: 'Here is a serene landscape photo from Uncle Jorge showing calm morning lake water reflecting pine trees and soft morning clouds.',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),

    // ─── 10. Little Leo (3 posts) ───────────────────────────────────────────
    PostModel(
      id: 'post-128', authorId: 'member-leo', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Look Grandma Rosa! I built a giant colorful Lego spaceship tower all by myself! Ready to fly to the moon! 🚀',
      mediaUrl: 'https://images.unsplash.com/photo-1585366119957-e9730b6d0f60?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Lego Spaceship',
      aiNarrationText: 'Here is a playful photo of your great-grandson Little Leo proudly displaying a tall colorful Lego spaceship tower he constructed.',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    PostModel(
      id: 'post-129', authorId: 'member-leo', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'My very first day of preschool! I love my new red rocket ship backpack and matching shoes! 🎒',
      mediaUrl: 'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'First Day of School',
      aiNarrationText: 'Here is a milestone photo of Little Leo smiling brightly on his first day of preschool wearing a new red backpack ready for class.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    PostModel(
      id: 'post-130', authorId: 'member-leo', familyId: sampleFamilyId, type: PostType.photo,
      caption: 'Splashing and running through the backyard sprinkler with David! Best summer afternoon ever! 💦',
      mediaUrl: 'https://images.unsplash.com/photo-1530549387789-4c1017266635?auto=format&fit=crop&w=800&q=80',
      source: PostSource.native, occasion: 'Water Fun',
      aiNarrationText: 'Here is a joyful summer photo of Little Leo laughing as he jumps through a water sprinkler on a sunny green lawn.',
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
  ];

  static List<ChatThreadModel> get sampleThreads => [
    ChatThreadModel(
      id: 'thread-group', familyId: sampleFamilyId, isGroup: true,
      title: 'Family Sunday Dinners ',
      participantIds: ['member-rosa', 'member-carlos', 'member-elena', 'member-david', 'member-maria'],
      lastMessagePreview: 'Grandma Rosa: I love you all so much! See you at 5pm! ',
      lastMessageTimestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    ChatThreadModel(
      id: 'thread-david', familyId: sampleFamilyId, isGroup: false,
      title: 'David & Grandma Rosa ',
      participantIds: ['member-rosa', 'member-david'],
      lastMessagePreview: 'David: I\'m coming over Wednesday to fix your TV remote Grandma!',
      lastMessageTimestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    ChatThreadModel(
      id: 'thread-elena', familyId: sampleFamilyId, isGroup: false,
      title: 'Elena & Grandma Rosa ',
      participantIds: ['member-rosa', 'member-elena'],
      lastMessagePreview: 'Elena: I will pick you up at 1:30 for your appointment Mom!',
      lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ChatThreadModel(
      id: 'thread-carlos', familyId: sampleFamilyId, isGroup: false,
      title: 'Carlos & Grandma Rosa ',
      participantIds: ['member-rosa', 'member-carlos'],
      lastMessagePreview: 'Carlos: Can\'t wait for our Sunday barbecue Mom!',
      lastMessageTimestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    ChatThreadModel(
      id: 'thread-maria', familyId: sampleFamilyId, isGroup: false,
      title: 'Maria & Grandma Rosa ',
      participantIds: ['member-rosa', 'member-maria'],
      lastMessagePreview: 'Maria: I updated the family tree with Cousin Mateo\'s puppy!',
      lastMessageTimestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    ChatThreadModel(
      id: 'thread-junior', familyId: sampleFamilyId, isGroup: false,
      title: 'Junior & Grandma Rosa ',
      participantIds: ['member-rosa', 'member-junior'],
      lastMessagePreview: 'Junior: Thanks for wishing me luck on my science project Grandma!',
      lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ChatThreadModel(
      id: 'thread-jorge', familyId: sampleFamilyId, isGroup: false,
      title: 'Uncle Jorge & Rosa ',
      participantIds: ['member-rosa', 'member-jorge'],
      lastMessagePreview: 'Uncle Jorge: Thank you for the sweet birthday wishes sister!',
      lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ChatThreadModel(
      id: 'thread-sofia', familyId: sampleFamilyId, isGroup: false,
      title: 'Aunt Sofia & Rosa ',
      participantIds: ['member-rosa', 'member-sofia'],
      lastMessagePreview: 'Aunt Sofia: Left some fresh garden lilies on your porch!',
      lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 4)),
    ),
    ChatThreadModel(
      id: 'thread-mateo', familyId: sampleFamilyId, isGroup: false,
      title: 'Cousin Mateo & Grandma Rosa ',
      participantIds: ['member-rosa', 'member-mateo'],
      lastMessagePreview: 'Cousin Mateo: Buddy sends puppy kisses Grandma!',
      lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ChatThreadModel(
      id: 'thread-leo', familyId: sampleFamilyId, isGroup: false,
      title: 'Little Leo & Grandma Rosa ',
      participantIds: ['member-rosa', 'member-leo'],
      lastMessagePreview: 'Little Leo: Look how high I can jump Grandma!',
      lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 6)),
    ),
  ];

  static List<ChatMessageModel> getSampleMessages(String threadId) {
    if (threadId == 'thread-group') {
      return [
        ChatMessageModel(
          id: 'msg-g1', threadId: 'thread-group', senderId: 'member-david',
          content: 'Hey everyone! Who is coming over for Sunday dinner at Grandma\'s this week? ',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ChatMessageModel(
          id: 'msg-g2', threadId: 'thread-group', senderId: 'member-carlos',
          content: 'I\'ll bring the marinated carne asada and drinks! Can\'t wait to see the whole family!',
          createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        ),
        ChatMessageModel(
          id: 'msg-g3', threadId: 'thread-group', senderId: 'member-elena',
          content: 'Mom and I are making fresh guacamole and Mexican rice right now! The kitchen smells amazing! ',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        ChatMessageModel(
          id: 'msg-g4', threadId: 'thread-group', senderId: 'member-maria',
          content: 'I\'m bringing chocolate tres leches cake for dessert! Be there at 5! ',
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
        ChatMessageModel(
          id: 'msg-g5', threadId: 'thread-group', senderId: 'member-rosa',
          content: 'I love you all so much my darlings! See you at 5pm! My heart is so full! ',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ];
    } else if (threadId == 'thread-david') {
      return [
        ChatMessageModel(
          id: 'msg-d1', threadId: 'thread-david', senderId: 'member-david',
          content: 'Hi Grandma! How did you like the photos from my graduation ceremony yesterday?',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        ChatMessageModel(
          id: 'msg-d2', threadId: 'thread-david', senderId: 'member-rosa',
          content: 'David my sweet boy, you looked so handsome in your robe! I showed your picture to all my friends at the garden club! I am so proud of you! ',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        ChatMessageModel(
          id: 'msg-d3', threadId: 'thread-david', senderId: 'member-david',
          content: 'Thank you Grandma!! That means the world to me. I\'m coming over Wednesday after work to fix your TV remote and bring you some groceries! Love you!',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
      ];
    } else if (threadId == 'thread-elena') {
      return [
        ChatMessageModel(
          id: 'msg-e1', threadId: 'thread-elena', senderId: 'member-elena',
          content: 'Good morning Mom! Just a reminder about your eye doctor checkup at 2pm today. I will come pick you up at 1:30pm!',
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        ),
        ChatMessageModel(
          id: 'msg-e2', threadId: 'thread-elena', senderId: 'member-rosa',
          content: 'Thank you Elena my love! I am ready and wearing my comfortable blue sweater. See you at 1:30! ',
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        ),
      ];
    } else if (threadId == 'thread-carlos') {
      return [
        ChatMessageModel(
          id: 'msg-c1', threadId: 'thread-carlos', senderId: 'member-carlos',
          content: 'Hi Mom! Are we still on for the Sunday family barbecue at 5pm?',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        ChatMessageModel(
          id: 'msg-c2', threadId: 'thread-carlos', senderId: 'member-rosa',
          content: 'Yes Carlos my son! I am preparing the sweet bread and beans now! So excited to see you!',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ];
    } else if (threadId == 'thread-maria') {
      return [
        ChatMessageModel(
          id: 'msg-m1', threadId: 'thread-maria', senderId: 'member-maria',
          content: 'Hi Grandma Rosa! I just added Uncle Jorge\'s 60th birthday celebration photos to our family tree!',
          createdAt: DateTime.now().subtract(const Duration(hours: 7)),
        ),
        ChatMessageModel(
          id: 'msg-m2', threadId: 'thread-maria', senderId: 'member-rosa',
          content: 'Thank you Maria my dear! You are such a wonderful blessing keeping our family memories organized!',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ];
    } else if (threadId == 'thread-junior') {
      return [
        ChatMessageModel(
          id: 'msg-j1', threadId: 'thread-junior', senderId: 'member-junior',
          content: 'Grandma I won 1st place at the Regional High School Science Fair with my robotic arm!',
          createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
        ),
        ChatMessageModel(
          id: 'msg-j2', threadId: 'thread-junior', senderId: 'member-rosa',
          content: 'Oh Junior I am leaping with joy! You are so brilliant my grandson, your grandfather would be so proud!',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
    } else if (threadId == 'thread-jorge') {
      return [
        ChatMessageModel(
          id: 'msg-jo1', threadId: 'thread-jorge', senderId: 'member-jorge',
          content: 'Thank you sister for the delicious chocolate cake and heartfelt wishes on my 60th birthday!',
          createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
        ),
        ChatMessageModel(
          id: 'msg-jo2', threadId: 'thread-jorge', senderId: 'member-rosa',
          content: 'You deserve all the happiness in the world Jorge! Happy birthday my dear brother!',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];
    } else if (threadId == 'thread-sofia') {
      return [
        ChatMessageModel(
          id: 'msg-s1', threadId: 'thread-sofia', senderId: 'member-sofia',
          content: 'Hi Rosa! I left a vase of fresh watercolor spring lilies from my garden on your front porch!',
          createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 3)),
        ),
        ChatMessageModel(
          id: 'msg-s2', threadId: 'thread-sofia', senderId: 'member-rosa',
          content: 'They are absolutely gorgeous Sofia! You have such a magical touch with flowers, thank you!',
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
      ];
    } else if (threadId == 'thread-mateo') {
      return [
        ChatMessageModel(
          id: 'msg-ma1', threadId: 'thread-mateo', senderId: 'member-mateo',
          content: 'Grandma look at my new golden retriever puppy Buddy! He loves his squeaky toys!',
          createdAt: DateTime.now().subtract(const Duration(days: 5, hours: 6)),
        ),
        ChatMessageModel(
          id: 'msg-ma2', threadId: 'thread-mateo', senderId: 'member-rosa',
          content: 'He is such an adorable little fur baby Mateo! Please bring him over soon so I can pet him!',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];
    } else if (threadId == 'thread-leo') {
      return [
        ChatMessageModel(
          id: 'msg-l1', threadId: 'thread-leo', senderId: 'member-leo',
          content: 'Look how high I can swing at the park Grandma Rosa! Watch my photo!',
          createdAt: DateTime.now().subtract(const Duration(days: 6, hours: 2)),
        ),
        ChatMessageModel(
          id: 'msg-l2', threadId: 'thread-leo', senderId: 'member-rosa',
          content: 'You are flying high like a little eagle my sweet Leo! Grandma loves you so much!',
          createdAt: DateTime.now().subtract(const Duration(days: 6)),
        ),
      ];
    }
    final memberId = 'member-${threadId.replaceAll('thread-', '')}';
    final member = sampleMembers.where((m) => m.id == memberId).firstOrNull;
    final name = member?.displayName ?? 'Family Member';
    return [
      ChatMessageModel(
        id: 'msg-def-1', threadId: threadId, senderId: member?.id ?? 'member-maria',
        content: 'Hi Grandma! It is so wonderful to stay connected with you here!',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChatMessageModel(
        id: 'msg-def-2', threadId: threadId, senderId: 'member-rosa',
        content: 'Hello $name my darling! I love seeing your updates every day!',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  static Future<void> seedAll(BuildContext context) async {
    await AuthService.signInAnonymously();
    final db = FirebaseFirestore.instance;
    const famId = sampleFamilyId;
    final batch = db.batch();

    final famRef = db.collection('families').doc(famId);
    batch.set(famRef, {
      'name': 'The Alvarez Family',
      'createdBy': 'member-rosa',
      'createdAt': FieldValue.serverTimestamp(),
    });

    for (final m in sampleMembers) {
      final docRef = db.collection('families').doc(famId).collection('members').doc(m.id);
      batch.set(docRef, m.toMap());
    }

    for (final p in samplePosts) {
      final postRef = db.collection('posts').doc(p.id);
      batch.set(postRef, p.toMap());
    }

    for (final t in sampleThreads) {
      final threadRef = db.collection('families').doc(famId).collection('chatThreads').doc(t.id);
      batch.set(threadRef, t.toMap());
    }

    for (final t in sampleThreads) {
      final msgs = getSampleMessages(t.id);
      for (final m in msgs) {
        final msgRef = db.collection('families').doc(famId).collection('chatThreads').doc(t.id).collection('messages').doc(m.id);
        batch.set(msgRef, m.toMap());
      }
    }

    final metaRef = db.collection('devMeta').doc('seeded');
    batch.set(metaRef, {'seededAt': FieldValue.serverTimestamp(), 'version': 2});

    try {
      await batch.commit().timeout(
        const Duration(seconds: 15),
      );
    } catch (_) {
      // In web/demo mode without backend, ignore error since memory providers already have the sample data!
    }
  }
}
