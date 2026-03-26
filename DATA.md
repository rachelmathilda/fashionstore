# Vaelys Data Schema

## Entities

### User

| Field | Type | Description |
|---|---|---|
| `user_id` | UUID | Primary key |
| `name` | string | Full name |
| `email` | string | Unique email |
| `gender` | enum: `male`, `female`, `unisex` | |
| `birth_date` | date | |
| `profile_photo_url` | string (URL) | |
| `created_at` | datetime | |

---

### UserBodyProfile

| Field | Type | Description |
|---|---|---|
| `user_id` | UUID (FK → User) | |
| `height_cm` | float | |
| `weight_kg` | float | |
| `body_type` | enum: `petite`, `slim`, `athletic`, `average`, `curvy`, `plus` | |
| `top_size` | enum: `XS`, `S`, `M`, `L`, `XL`, `XXL` | |
| `bottom_size` | enum: `XS`, `S`, `M`, `L`, `XL`, `XXL` | |
| `shoe_size_eu` | float | |
| `skin_tone` | enum: `fair`, `light`, `medium`, `tan`, `deep` | |
| `updated_at` | datetime | |

---

### UserStyleProfile

| Field | Type | Description |
|---|---|---|
| `user_id` | UUID (FK → User) | |
| `preferred_styles` | list\<enum\> | `casual`, `formal`, `streetwear`, `bohemian`, `minimalist`, `sporty`, `vintage`, `preppy` |
| `preferred_colors` | list\<string\> | Hex or color name |
| `disliked_colors` | list\<string\> | Hex or color name |
| `preferred_patterns` | list\<enum\> | `solid`, `stripes`, `plaid`, `floral`, `abstract`, `animal_print` |
| `preferred_occasions` | list\<enum\> | `daily`, `work`, `party`, `outdoor`, `sport`, `formal_event` |
| `budget_min_idr` | integer | |
| `budget_max_idr` | integer | |
| `updated_at` | datetime | |

---

### Product

| Field | Type | Description |
|---|---|---|
| `product_id` | UUID | Primary key |
| `name` | string | |
| `brand` | string | |
| `category` | enum | `top`, `bottom`, `dress`, `outerwear`, `footwear`, `accessory`, `bag` |
| `subcategory` | string | e.g. `t-shirt`, `skirt`, `blazer`, `sneakers` |
| `gender_target` | enum: `male`, `female`, `unisex` | |
| `style_tags` | list\<enum\> | Same values as `preferred_styles` |
| `occasion_tags` | list\<enum\> | Same values as `preferred_occasions` |
| `color_primary` | string | Hex or color name |
| `color_secondary` | list\<string\> | |
| `pattern` | enum | Same values as `preferred_patterns` |
| `available_sizes` | list\<enum\> | |
| `price_idr` | integer | |
| `stock_count` | integer | |
| `image_urls` | list\<string (URL)\> | Multiple angles |
| `embedding_vector` | list\<float\> (512-dim) | CNN image embedding |
| `created_at` | datetime | |
| `is_active` | boolean | |

---

### OutfitSet

| Field | Type | Description |
|---|---|---|
| `outfit_id` | UUID | Primary key |
| `name` | string | e.g. `"Casual Monday Look"` |
| `created_by` | enum: `system`, `stylist`, `user` | |
| `style_tags` | list\<enum\> | Same values as `preferred_styles` |
| `occasion_tags` | list\<enum\> | Same values as `preferred_occasions` |
| `product_ids` | list\<UUID\> (FK → Product) | |
| `cover_image_url` | string (URL) | |
| `created_at` | datetime | |

---

### UserInteraction

| Field | Type | Description |
|---|---|---|
| `interaction_id` | UUID | Primary key |
| `user_id` | UUID (FK → User) | |
| `product_id` | UUID (FK → Product) | |
| `interaction_type` | enum | `view`, `wishlist`, `cart_add`, `purchase`, `review`, `share`, `try_on` |
| `interaction_weight` | float | Implicit weight (see table below) |
| `session_id` | UUID | |
| `timestamp` | datetime | |
| `metadata` | JSON | e.g. `{"duration_sec": 45}` |

**Interaction Weights:**

| `interaction_type` | `interaction_weight` |
|---|---|
| `view` | 1.0 |
| `wishlist` | 3.0 |
| `cart_add` | 4.0 |
| `try_on` | 3.5 |
| `share` | 2.5 |
| `purchase` | 5.0 |
| `review` | 4.5 |

---

### Order

| Field | Type | Description |
|---|---|---|
| `order_id` | UUID | Primary key |
| `user_id` | UUID (FK → User) | |
| `status` | enum | `pending`, `paid`, `processing`, `shipped`, `delivered`, `cancelled`, `returned` |
| `items` | list\<OrderItem\> | |
| `total_price_idr` | integer | |
| `shipping_address` | JSON | |
| `shipping_method` | string | |
| `payment_method` | string | |
| `created_at` | datetime | |
| `updated_at` | datetime | |

**OrderItem:**

| Field | Type | Description |
|---|---|---|
| `product_id` | UUID (FK → Product) | |
| `size` | string | |
| `quantity` | integer | |
| `unit_price_idr` | integer | Price at time of purchase |

---

### ImageSearchQuery

| Field | Type | Description |
|---|---|---|
| `query_id` | UUID | Primary key |
| `user_id` | UUID (FK → User) | Nullable for guest |
| `source_type` | enum | `upload`, `camera`, `checkout_screenshot` |
| `image_url` | string (URL) | |
| `image_embedding` | list\<float\> (512-dim) | CNN embedding of query image |
| `results` | list\<UUID\> (FK → Product) | Top-K returned products |
| `created_at` | datetime | |

---

## Sample Data

### User

```json
{
  "user_id": "usr-001",
  "name": "Alya Putri",
  "email": "alya@example.com",
  "gender": "female",
  "birth_date": "2001-04-15",
  "profile_photo_url": "https://cdn.example.com/users/usr-001.jpg",
  "created_at": "2024-10-01T08:00:00Z"
}
```

### UserBodyProfile

```json
{
  "user_id": "usr-001",
  "height_cm": 162.0,
  "weight_kg": 52.0,
  "body_type": "slim",
  "top_size": "S",
  "bottom_size": "S",
  "shoe_size_eu": 37.0,
  "skin_tone": "light",
  "updated_at": "2024-10-01T08:05:00Z"
}
```

### UserStyleProfile

```json
{
  "user_id": "usr-001",
  "preferred_styles": ["casual", "minimalist"],
  "preferred_colors": ["#FFFFFF", "#F5F5DC", "#C8A2C8", "navy"],
  "disliked_colors": ["neon_yellow", "orange"],
  "preferred_patterns": ["solid", "stripes"],
  "preferred_occasions": ["daily", "work"],
  "budget_min_idr": 100000,
  "budget_max_idr": 500000,
  "updated_at": "2025-01-15T10:30:00Z"
}
```

### Product

```json
{
  "product_id": "prd-001",
  "name": "Linen Oversized Shirt",
  "brand": "Vestya",
  "category": "top",
  "subcategory": "shirt",
  "gender_target": "female",
  "style_tags": ["casual", "minimalist"],
  "occasion_tags": ["daily", "work"],
  "color_primary": "#F5F5DC",
  "color_secondary": ["#FFFFFF"],
  "pattern": "solid",
  "available_sizes": ["XS", "S", "M", "L"],
  "price_idr": 285000,
  "stock_count": 42,
  "image_urls": [
    "https://cdn.example.com/products/prd-001-front.jpg",
    "https://cdn.example.com/products/prd-001-back.jpg"
  ],
  "embedding_vector": [0.12, -0.34, 0.55, "..."],
  "created_at": "2024-09-10T00:00:00Z",
  "is_active": true
}
```

### OutfitSet

```json
{
  "outfit_id": "out-001",
  "name": "Soft Office OOTD",
  "created_by": "stylist",
  "style_tags": ["minimalist", "casual"],
  "occasion_tags": ["work", "daily"],
  "product_ids": ["prd-001", "prd-047", "prd-112"],
  "cover_image_url": "https://cdn.example.com/outfits/out-001.jpg",
  "created_at": "2025-01-20T00:00:00Z"
}
```

### UserInteraction

```json
[
  {
    "interaction_id": "int-0021",
    "user_id": "usr-001",
    "product_id": "prd-001",
    "interaction_type": "view",
    "interaction_weight": 1.0,
    "session_id": "ses-abc123",
    "timestamp": "2025-02-10T14:23:00Z",
    "metadata": { "duration_sec": 38 }
  },
  {
    "interaction_id": "int-0022",
    "user_id": "usr-001",
    "product_id": "prd-001",
    "interaction_type": "cart_add",
    "interaction_weight": 4.0,
    "session_id": "ses-abc123",
    "timestamp": "2025-02-10T14:24:12Z",
    "metadata": {}
  }
]
```

### ImageSearchQuery

```json
{
  "query_id": "qry-0091",
  "user_id": "usr-001",
  "source_type": "checkout_screenshot",
  "image_url": "https://cdn.example.com/queries/qry-0091.jpg",
  "image_embedding": [0.08, 0.71, -0.22, "..."],
  "results": ["prd-001", "prd-033", "prd-078", "prd-201", "prd-309"],
  "created_at": "2025-02-10T14:21:00Z"
}
```
