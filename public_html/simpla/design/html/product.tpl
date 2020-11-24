{capture name=tabs}
	<li class="active"><a href="{url module=ProductsAdmin category_id=$product->category_id return=null brand_id=null id=null}">Товары</a></li>
	{if in_array('categories', $manager->permissions)}<li><a href="index.php?module=CategoriesAdmin">Категории</a></li>{/if}
	{if in_array('brands', $manager->permissions)}<li><a href="index.php?module=BrandsAdmin">Бренды</a></li>{/if}
	{if in_array('features', $manager->permissions)}<li><a href="index.php?module=FeaturesAdmin">Свойства</a></li>{/if}
{/capture}

{if $product->id}
	{$meta_title="{$product->name|escape}" scope=parent}
{else}
	{$meta_title="Новый товар" scope=parent}
{/if}

{include file='tinymce_init.tpl'}

{if $message_success}
<div class="message message_success">
	<span class="text">
		{if $message_success=='added'}
			Товар добавлен
		{elseif $message_success=='updated'}
			Товар изменен
		{else}
			{$message_success}
		{/if}
	</span>

	<a href="../products/{$product->url}" class="link" target="_blank">Открыть товар на сайте</a>

	{if $smarty.get.return}
		<a href="{$smarty.get.return}" class="button">Вернуться</a>
	{/if}

	<span class="share">
		<a href="#" onClick='window.open("http://vkontakte.ru/share.php?url={$config->root_url|urlencode}/products/{$product->url|urlencode}&title={$product->name|urlencode}&description={$product->annotation|urlencode}&image={$product_images.0->filename|resize:1000:1000|urlencode}&noparse=true","displayWindow","width=700,height=400,left=250,top=170,status=no,toolbar=no,menubar=no");return false;'>
			<img src="{$config->root_url}/simpla/design/images/vk_icon.png" />
		</a>

		<a href="#" onClick='window.open("http://www.facebook.com/sharer.php?u={$config->root_url|urlencode}/products/{$product->url|urlencode}","displayWindow","width=700,height=400,left=250,top=170,status=no,toolbar=no,menubar=no");return false;'>
			<img src="{$config->root_url}/simpla/design/images/facebook_icon.png" />
		</a>

		<a href="#" onClick='window.open("http://twitter.com/share?text={$product->name|urlencode}&url={$config->root_url|urlencode}/products/{$product->url|urlencode}&hashtags={$product->meta_keywords|replace:' ':''|urlencode}","displayWindow","width=700,height=400,left=250,top=170,status=no,toolbar=no,menubar=no");return false;'>
			<img src="{$config->root_url}/simpla/design/images/twitter_icon.png" />
		</a>
	</span>
</div>
{/if}

{if $message_error}
	<div class="message message_error">
		<span class="text">
			{if $message_error=='url_exists'}
				Товар с таким адресом уже существует
			{elseif $message_error=='empty_name'}
				Введите название
			{else}
				{$message_error}
			{/if}
		</span>
	</div>
{/if}

<form method="post" id="product" enctype="multipart/form-data">
	<input type="hidden" name="session_id" value="{$smarty.session.id}" />

	<div id="name">
		<input type="text" name="name" value="{$product->name|escape}" class="name" />

		<input type="hidden" name="id" value="{$product->id|escape}" />

		<div class="checkbox">
			<input type="checkbox" name="visible" value="1" id="active_checkbox" {if $product->visible}checked{/if} />
			<label for="active_checkbox">Активен</label>
		</div>

		<div class="checkbox">
			<input type="checkbox" name="featured" value="1" id="featured_checkbox" {if $product->featured}checked{/if} />
			<label for="featured_checkbox">Рекомендуемый</label>
		</div>
		
		<div class="checkbox">
            <input name=to_yandex value="1" type="checkbox" id="yandex_checkbox" {if $product->to_yandex}checked{/if}/> 
            <label for="yandex_checkbox">Yandex</label>
        </div>


		<div class="checkbox">
			<input type="checkbox" name="new" value="1" id="new_checkbox" {if $product->new}checked{/if} />
			<label for="new_checkbox">Новинка</label>
		</div>
	</div>

	<div id="product_brand" {if !$brands}style="display:none;"{/if}>
		<label>Бренд</label>

		<select name="brand_id">
			<option value="0" brand_name="" {if !$product->brand_id}selected{/if}>Не указан</option>

			{foreach $brands as $brand}
				<option value="{$brand->id}" brand_name="{$brand->name|escape}" {if $product->brand_id == $brand->id}selected{/if}>
					{$brand->name|escape}
				</option>
			{/foreach}
		</select>
	</div>

	<div id="product_categories" {if !$categories}style="display:none;"{/if}>
		<label>Категория</label>

		<div>
			<ul>
				{foreach $product_categories as $product_category name=categories}
					<li>
						<select name="categories[]">
							{function name=category_select level=0}
								{foreach $categories as $category}
									<option value="{$category->id}" category_name="{$category->name|escape}" {if $category->id == $selected_id}selected{/if}>
										{section name=sp loop=$level}&nbsp;&nbsp;&nbsp;{/section}{$category->name|escape}
									</option>

									{category_select categories=$category->subcategories selected_id=$selected_id level=$level+1}
								{/foreach}
							{/function}

							{category_select categories=$categories selected_id=$product_category->id}
						</select>

						<span class="add" {if not $smarty.foreach.categories.first}style="display:none;"{/if}>
							<i class="dash_link">Дополнительная категория</i>
						</span>

						<span class="delete" {if $smarty.foreach.categories.first}style="display:none;"{/if}>
							<i class="dash_link">Удалить</i>
						</span>
					</li>
				{/foreach}
			</ul>
		</div>
	</div>

	<div id="variants_block" {assign var=first_variant value=$product_variants|@first}{if $product_variants|@count <= 1 && !$first_variant->name}class="single_variant"{/if}>
		<ul id="header">
			<li class="variant_move"></li>
			<li class="variant_name">Название варианта</li>
			<li class="variant_sku">Артикул</li>
			<li class="variant_amount">От Кол-ва</li>
			<li class="variant_price">Цена, {$currency->sign}</li>
			<li class="variant_discount">Старая, {$currency->sign}</li>
			<li class="variant_amount">Наличие</li>
		</ul>

		<div id="variants">
			{foreach $product_variants as $variant}
				<ul>
					<li class="variant_move">
						<div class="move_zone"></div>
					</li>

					<li class="variant_name">
						<input type="hidden" name="variants[id][]" value="{$variant->id|escape}" />
						<input type="" name="variants[name][]" value="{$variant->name|escape}" />
						<a class="del_variant" href="">
							<img src="design/images/cross-circle-frame.png" title="Удалить" />
						</a>
					</li>

					<li class="variant_sku">
						<input type="text" name="variants[sku][]" value="{$variant->sku|escape}" />
					</li>

					<li class="variant_prices">
						{if $variant->prices}
						{foreach $variant->prices as $vp}
						<div>
							<input name="prices[id][]" type="hidden" value="{$vp->id|escape}">
							<input name="prices[variant_id][]" type="hidden" value="{$vp->variant_id|escape}">
							<div class="variant_amount">
								<input name="prices[from_amount][]" {if $vp->from_amount==1}readonly="readonly" class="readonly"{/if} type="text" value="{$vp->from_amount|escape}" />{$settings->units}
							</div>
							<div class="variant_price">
								<input name="prices[price][]"         type="text"   value="{$vp->price|escape}" />
							</div>
							<div class="variant_discount">
								<input name="prices[compare_price][]" type="text"   value="{$vp->compare_price|escape}" />
							</div>
						</div>
						{/foreach}
						<div class="insertBefore" style="clear: both"></div>
						<span class="add_btn_small really_add"><i class="dash_link">Добавить цену</i></span>
						{else}
						<div>
							<div class="variant_amount">
								<input name="dummy_amount" disabled="disabled" type="text" value="1" />{$settings->units}
							</div>
							<div class="variant_price">
								<input name="variants[price][]"         type="text"   value="" />
							</div>
							<div class="variant_discount">
								<input name="variants[compare_price][]" type="text"   value="" />
							</div>
						</div>
						<div class="insertBefore" style="clear: both"></div>
						<span class="add_btn_small really_save"><i class="dash_link">Добавить цену *сохранить</i></span>
						{/if}

						<div class="checkbox">
							<input name="variants[prices_ask][]" value="1" type="checkbox" id="prices_ask" {if $variant->prices_ask}checked{/if} /> 
							<label for="prices_ask">Цена по запросу</label>
						</div>

					</li>

					<li class="variant_amount">
						<input type="text" name="variants[stock][]" value="{if $variant->infinity || $variant->stock == ''}∞{else}{$variant->stock|escape}{/if}" />
						{$settings->units}
					</li>

					<li class="variant_download">
						{if $variant->attachment}
							<span class="attachment_name">{$variant->attachment|truncate:25:'...':false:true}</span>

							<a href="#" class="remove_attachment">
								<img src="design/images/bullet_delete.png" title="Удалить цифровой товар" />
							</a>

							<a href="#" class="add_attachment" style="display:none;">
								<img src="design/images/cd_add.png" title="Добавить цифровой товар" />
							</a>
						{else}
							<a href="#" class="add_attachment">
								<img src="design/images/cd_add.png" title="Добавить цифровой товар" />
							</a>
						{/if}

						<div class="browse_attachment" style="display:none;">
							<input type="file" name="attachment[]" />
							<input type="hidden" name="delete_attachment[]" />
						</div>
					</li>
				</ul>
			{/foreach}
		</div>

		<ul id="new_variant" style="display:none;">
			<li class="variant_move">
				<div class="move_zone"></div>
			</li>

			<li class="variant_name">
				<input type="hidden" name="variants[id][]" value="" />

				<input type="" name="variants[name][]" value="" />

				<a href="#" class="del_variant" >
					<img src="design/images/cross-circle-frame.png" title="Удалить" />
				</a>
			</li>

			<li class="variant_sku">
				<input type="" name="variants[sku][]" value="" />
			</li>

			<li class="variant_prices">
				<div>
					<div class="variant_amount">
						<input name="dummy_amount" disabled="disabled" type="text" value="1" />{$settings->units}
					</div>
					<div class="variant_price">
						<input name="variants[price][]"         type="text"   value="" />
					</div>
					<div class="variant_discount">
						<input name="variants[compare_price][]" type="text"   value="" />
					</div>
				</div>
				<div style="clear: both"></div>
			</li>

			<li class="variant_amount">
				<input type="" name="variants[stock][]" value="∞" />
				{$settings->units}
			</li>

			<li class="variant_download">
				<a href="#" class="add_attachment">
					<img src="design/images/cd_add.png" />
				</a>

				<div class="browse_attachment" style="display:none;">
					<input type="file" name="attachment[]" />

					<input type="hidden" name="delete_attachment[]" />
				</div>
			</li>
		</ul>

		<div id="new_price" style="display: none;">
			<input name="prices[id][]" type="hidden" value="">
			<input name="prices[variant_id][]" type="hidden" value="">
			<div class="variant_amount">
				<input name="prices[from_amount][]"  type="text" value="" />{$settings->units}
			</div>
			<div class="variant_price">
				<input name="prices[price][]"         type="text"   value="" />
			</div>
			<div class="variant_discount">
				<input name="prices[compare_price][]" type="text"   value="" />
			</div>
		</div>

		<input class="button_green button_save" type="submit" name="" value="Сохранить" />
		<span class="add" id="add_variant"><i class="dash_link">Добавить вариант</i></span>
	</div>

	<div id="column_left">
		<div class="block layer">
			<h2>Параметры страницы</h2>

			<ul>
				<li>
					<label class="property">Адрес</label>
					<div class="page_url">/products/</div>
					<input type="text" name="url" value="{$product->url|escape}" class="page_url" />
				</li>

				<li>
					<label class="property">Заголовок</label>
					<input type="text" name="meta_title" value="{$product->meta_title|escape}" class="simpla_inp" />
				</li>

				<li>
					<label class="property">Ключевые слова</label>
					<input type="text" name="meta_keywords" value="{$product->meta_keywords|escape}" class="simpla_inp" />
				</li>

				<li>
					<label class="property">Описание</label>
					<textarea name="meta_description" class="simpla_inp">{$product->meta_description|escape}</textarea>
				</li>
			</ul>
		</div>

		<div class="block layer" {if !$categories}style="display:none;"{/if}>
			<h2>
				Свойства товара <a href="#" id="properties_wizard"><img src="design/images/wand.png" title="Подобрать автоматически" /></a>
			</h2>

			<ul class="prop_ul">
				{foreach $features as $feature}
					{assign var=feature_id value=$feature->id}

					<li feature_id="{$feature_id}">
						<label class="property">{$feature->name|escape}</label>
						<input type="text" name="options[{$feature_id|escape}]" value="{$options.$feature_id->value|escape}" class="simpla_inp" />
					</li>
				{/foreach}
			</ul>

			<ul class="new_features">
				<li id="new_feature">
					<label class="property">
						<input type="text" name="new_features_names[]" />
					</label>

					<input type="text" name="new_features_values[]" class="simpla_inp" />
				</li>
			</ul>

			<span class="add">
				<i id="add_new_feature" class="dash_link">Добавить новое свойство</i>
			</span>

			<input type="submit" name="" value="Сохранить" class="button_green button_save" />
		</div>

		{*
		<div class="block">
			<h2>Экспорт товара</h2>

			<ul>
				<li>
					<input type="checkbox" id="exp_yad" />
					<label for="exp_yad">Яндекс Маркет</label> Бид <input type="" name="" value="12" class="simpla_inp" /> руб.
				</li>

				<li>
					<input id="exp_goog" type="checkbox" />
					<label for="exp_goog">Google Base</label>
				</li>
			</ul>
		</div>
		*}
	</div>

	<div id="column_right">
		<div class="block layer images">
			<h2>
				Изображения товара <a href="#" id="images_wizard"><img src="design/images/wand.png" title="Подобрать автоматически" /></a>
			</h2>

			<ul>
				{foreach $product_images as $image}
					<li>
						<a href="#" class="delete">
							<img src="design/images/cross-circle-frame.png" title="Удалить">
						</a>

						<img src="{$image->filename|resize:100:100}" />

						<input type="hidden" name="images[]" value="{$image->id}" />
					</li>
				{/foreach}
			</ul>

			<div id="dropZone">
				<div id="dropMessage">Перетащите файлы сюда</div>

				<input type="file" name="dropped_images[]" multiple class="dropInput" />
			</div>

			<div id="add_image"></div>

			<span class="upload_image">
				<i id="upload_image" class="dash_link">Добавить изображение</i></span> или <span class="add_image_url"><i id="add_image_url" class="dash_link">загрузить из интернета</i>
			</span>
		</div>

		<div class="related_products_wrap block layer">
			<h2>Связанные товары</h2>

			<div id="list" class="sortable related_products">
				{foreach $related_products as $related_product}
					<div class="row">
						<div class="move cell">
							<div class="move_zone"></div>
						</div>

						<div class="image cell">
							<input type="hidden" name="related_products[]" value="{$related_product->id}" />

							<a href="{url id=$related_product->id}">
								<img class="product_icon" src="{$related_product->images[0]->filename|resize:35:35}" />
							</a>
						</div>

						<div class="name cell">
							<a href="{url id=$related_product->id}">{$related_product->name|escape}</a>
						</div>

						<div class="icons cell">
							<a href="#" class="delete" title="Удалить"></a>
						</div>

						<div class="clear"></div>
					</div>
				{/foreach}

				<div id="new_related_product" class="row" style="display:none;">
					<div class="move cell">
						<div class="move_zone"></div>
					</div>

					<div class="image cell">
						<input type="hidden" name="related_products[]" value="" />

						<img class="product_icon" src="" />
					</div>

					<div class="name cell">
						<a href="#" class="related_product_name"></a>
					</div>

					<div class="icons cell">
						<a href="#" class="delete" title="Удалить"></a>
					</div>

					<div class="clear"></div>
				</div>
			</div>

			<input type="text" name="related" id="related_products" class="input_autocomplete" placeholder="Выберите товар чтобы добавить его" />

			<input type="submit" name="" value="Сохранить" class="button_green button_save" />
		</div>
	</div>

	<div class="block layer">
		<h2>Краткое описание</h2>

		<textarea name="annotation" class="editor_small">{$product->annotation|escape}</textarea>
	</div>

	<div class="block">
		<h2>Полное  описание</h2>

		<textarea name="body" class="editor_large">{$product->body|escape}</textarea>
	</div>

	<input type="submit" name="" value="Сохранить" class="button_green button_save" />
</form>

{literal}
<script>
$(function() {
	// Удаление цены
	$('a.del_price').click(function() {
		if($("#variants ul").size()>1)
		{
			$(this).closest("ul").fadeOut(200, function() { $(this).remove(); });
		}
	});

	// Добавление цен
	var new_price = $('#new_price').clone(true);
	$('#new_price').remove().removeAttr('id');
	$('.variant_prices .really_add').click(function() {

		variant_id = $(this).parents('ul').find("input[name*=variants][name*=id]").val();
		where_to_insert = $(this).parent().find(".insertBefore");
		$(new_price).find("input[name*=prices][name*=variant_id]").val(variant_id);
		$(new_price).clone(true).insertBefore(where_to_insert).fadeIn('slow').find("input[name*=prices][name*=price]").focus();
		return false;

	});

	$('.variant_prices .really_save').click(function() {

		$(this).parents('form').submit();

	});

	// Добавление категории
	$('#product_categories .add').click(function() {
		$('#product_categories ul li:last').clone(false).appendTo('#product_categories ul').fadeIn('slow').find('select[name*="categories"]:last').focus();
		$('#product_categories ul li:last span.add').hide();
		$('#product_categories ul li:last span.delete').show();
		return false;
	});

	// Удаление категории
	$('#product_categories .delete').click(function() {
		$(this).closest('li').fadeOut(200, function() { $(this).remove(); });
		return false;
	});

	// Сортировка вариантов
	$('#variants_block').sortable({ items: '#variants ul' , axis: 'y',  cancel: '#header', handle: '.move_zone' });
	$('table.related_products').sortable({ items: 'tr' , axis: 'y',  cancel: '#header', handle: '.move_zone' });

	// Сортировка связанных товаров
	$('.sortable').sortable({
		items: '.row',
		tolerance: 'pointer',
		scrollSensitivity: 40,
		opacity: 0.7,
		handle: '.move_zone'
	});

	// Сортировка изображений
	$('.images ul').sortable({ tolerance: 'pointer'});

	// Удаление изображений
	$('.images a.delete').click(function() {
		$(this).closest("li").fadeOut(200, function() { $(this).remove(); });
		return false;
	});

	// Загрузить изображение с компьютера
	$('#upload_image').click(function() {
		$('<input type="file" name="images[]" class="upload_image" multiple accept="image/jpeg,image/png,image/gif" />').appendTo('div#add_image').focus().click();
	});

	// Или с URL
	$('#add_image_url').click(function() {
		$('<input type="text" name="images_urls[]" value="http://" class="remote_image" />').appendTo('div#add_image').focus().select();
	});

	// Или перетаскиванием
	if(window.File && window.FileReader && window.FileList)
	{
		$('#dropZone').show();
		$('#dropZone').on('dragover', function (e) {
			$(this).css('border', '1px solid #8cbf32');
		});
		$(document).on('dragenter', function (e) {
			$('#dropZone').css('border', '1px dotted #8cbf32').css('background-color', '#c5ff8d');
		});

		dropInput = $('.dropInput').last().clone();

		function handleFileSelect(evt) {
			var files = evt.target.files; // FileList object
			// Loop through the FileList and render image files as thumbnails.
			for (var i = 0, f; f = files[i]; i++) {
				// Only process image files.
				if (!f.type.match('image.*')) {
					continue;
				}
			var reader = new FileReader();
			// Closure to capture the file information.
			reader.onload = (function(theFile) {
				return function(e) {
					// Render thumbnail.
					$("<li class='wizard'><a href='#' class='delete' title='Удалить'><img src='design/images/cross-circle-frame.png' /></a><img onerror='$(this).closest(\"li\").remove();' src='"+e.target.result+"' /><input type='hidden' name='images_urls[]' value='"+theFile.name+"' /></li>").appendTo('div .images ul');
					temp_input =  dropInput.clone();
					$('.dropInput').hide();
					$('#dropZone').append(temp_input);
					$("#dropZone").css('border', '1px solid #d0d0d0').css('background-color', '#ffffff');
					clone_input.show();
				};
				})(f);

				// Read in the image file as a data URL.
				reader.readAsDataURL(f);
			}
		}
		$('.dropInput').live('change', handleFileSelect);
	};

	// Удаление варианта
	$('a.del_variant').click(function() {
		if($('#variants ul').size()>1)
		{
			$(this).closest('ul').fadeOut(200, function() { $(this).remove(); });
		}
		else
		{
			$('#variants_block .variant_name input[name*="variant"][name*="name"]').val('');
			$('#variants_block .variant_name').hide('slow');
			$('#variants_block').addClass('single_variant');
		}
		return false;
	});

	// Загрузить файл к варианту
	$('#variants_block a.add_attachment').click(function() {
		$(this).hide();
		$(this).closest('li').find('div.browse_attachment').show('fast');
		$(this).closest('li').find('input[name*="attachment"]').attr('disabled', false);
		return false;
	});

	// Удалить файл к варианту
	$('#variants_block a.remove_attachment').click(function() {
		closest_li = $(this).closest('li');
		closest_li.find('.attachment_name').hide('fast');
		$(this).hide('fast');
		closest_li.find('input[name*="delete_attachment"]').val('1');
		closest_li.find('a.add_attachment').show('fast');
		return false;
	});

	// Добавление варианта
	var variant = $('#new_variant').clone(true);
	$('#new_variant').remove().removeAttr('id');
	$('#variants_block span.add').click(function() {
		if(!$('#variants_block').is('.single_variant'))
		{
			$(variant).clone(true).appendTo('#variants').fadeIn('slow').find('input[name*="variant"][name*="name"]').focus();
		}
		else
		{
			$('#variants_block .variant_name').show('slow');
			$('#variants_block').removeClass('single_variant');
		}
		return false;
	});


	function show_category_features(category_id)
	{
		$('ul.prop_ul').empty();
		$.ajax({
			url: 'ajax/get_features.php',
			data: {category_id: category_id, product_id: $('input[name="id"]').val()},
			dataType: 'json',
			success: function(data){
				for(i=0; i<data.length; i++)
				{
					feature = data[i];

					line = $('<li><label class="property"></label><input type="text" class="simpla_inp" /></li>');
					var new_line = line.clone(true);
					new_line.find('label.property').text(feature.name);
					new_line.find('input').attr('name', 'options['+feature.id+']').val(feature.value);
					new_line.appendTo('ul.prop_ul').find('input')
					.autocomplete({
						serviceUrl: 'ajax/options_autocomplete.php',
						minChars: 0,
						params: {feature_id:feature.id},
						noCache: false
					});
				}
			}
		});
		return false;
	}

	// Изменение набора свойств при изменении категории
	$('select[name="categories[]"]:first').change(function() {
		show_category_features($('option:selected',this).val());
	});

	// Автодополнение свойств
	$('ul.prop_ul input[name*="options"]').each(function(index) {
		feature_id = $(this).closest('li').attr('feature_id');
		$(this).autocomplete({
			serviceUrl: 'ajax/options_autocomplete.php',
			minChars: 0,
			params: {feature_id:feature_id},
			noCache: false
		});
	});

	// Добавление нового свойства товара
	var new_feature = $('#new_feature').clone(true);
	$('#new_feature').remove().removeAttr('id');
	$('#add_new_feature').click(function() {
		$(new_feature).clone(true).appendTo('ul.new_features').fadeIn('slow').find('input[name*="new_feature_name"]').focus();
		return false;
	});

	// Удаление связанного товара
	$('.related_products a.delete').live('click', function() {
		$(this).closest('.row').fadeOut(200, function() { $(this).remove(); });
		return false;
	});

	// Добавление связанного товара
	var new_related_product = $('#new_related_product').clone(true);
	$('#new_related_product').remove().removeAttr('id');

	$('input#related_products').autocomplete({
		serviceUrl: 'ajax/search_products.php',
		minChars: 0,
		noCache: false,
		onSelect:
			function(suggestion){
				$("input#related_products").val('').focus().blur();
				new_item = new_related_product.clone().appendTo('.related_products');
				new_item.removeAttr('id');
				new_item.find('a.related_product_name').html(suggestion.data.name);
				new_item.find('a.related_product_name').attr('href', 'index.php?module=ProductAdmin&id='+suggestion.data.id);
				new_item.find('input[name*="related_products"]').val(suggestion.data.id);
				if(suggestion.data.image)
					new_item.find('img.product_icon').attr("src", suggestion.data.image);
				else
					new_item.find('img.product_icon').remove();
				new_item.show();
			},
		formatResult:
			function(suggestions, currentValue){
				var reEscape = new RegExp('(\\' + ['/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\'].join('|\\') + ')', 'g');
				var pattern = '(' + currentValue.replace(reEscape, '\\$1') + ')';
				return (suggestions.data.image?"<img align='absmiddle' src='"+suggestions.data.image+"'> ":'') + suggestions.value.replace(new RegExp(pattern, 'gi'), '<strong>$1<\/strong>');
			}

	});

	// infinity
	$('input[name*="variant"][name*="stock"]').focus(function() {
		if($(this).val() == '∞')
			$(this).val('');
		return false;
	});

	$('input[name*="variant"][name*="stock"]').blur(function() {
		if($(this).val() == '')
			$(this).val('∞');
	});

	// Волшебные изображения
	name_changed = false;
	$('input[name=name]').change(function() {
		name_changed = true;
		images_loaded = 0;
	});
	images_num = 8;
	images_loaded = 0;
	old_wizar_dicon_src = $('#images_wizard img').attr('src');
	$('#images_wizard').click(function() {

		$('#images_wizard img').attr('src', 'design/images/loader.gif');
		if(name_changed)
			$('div.images ul li.wizard').remove();
		name_changed = false;
		key = $('input[name="name"]').val();
		$.ajax({
				url: "ajax/get_images.php",
				data: {keyword: key, start: images_loaded},
				dataType: 'json',
				success: function(data){
					for(i=0; i<Math.min(data.length, images_num); i++)
					{
						image_url = data[i];
						$("<li class='wizard'><a href='' class='delete' title='Удалить'><img src='design/images/cross-circle-frame.png'></a><a href='"+image_url+"' target=_blank><img onerror='$(this).closest(\"li\").remove();' src='"+image_url+"' /><input name=images_urls[] type=hidden value='"+image_url+"'></a></li>").appendTo('div .images ul');
					}
					$('#images_wizard img').attr('src', old_wizar_dicon_src);
					images_loaded += images_num;
				}
		});
		return false;
	});

	// Волшебное описание
	name_changed = false;
	captcha_code = '';
	$('input[name="name"]').change(function() {
		name_changed = true;
	});

	old_prop_wizard_icon_src = $('#properties_wizard img').attr('src');
	$('#properties_wizard').click(function() {

		$('#properties_wizard img').attr('src', 'design/images/loader.gif');
		$('#captcha_form').remove();
		if(name_changed)
			$('div.images ul li.wizard').remove();
		name_changed = false;
		key = $('input[name="name"]').val();

		$.ajax({
				url: "ajax/get_info.php",
				data: {keyword: key, captcha: captcha_code},
				dataType: 'json',
				success: function(data){

					captcha_code = '';
					$('#properties_wizard img').attr('src', old_prop_wizard_icon_src);

					// Если запрашивают капчу
					if(data.captcha)
					{
						captcha_form = $("<form id='captcha_form'><img align='absmiddle' src='data:image/png;base64,"+data.captcha+"' /><input type='text' id='captcha_input' /><input type='submit' value='Ok' /></form>");
						$('#properties_wizard').parent().append(captcha_form);
						$('#captcha_input').focus();
						captcha_form.submit(function() {
							captcha_code = $('#captcha_input').val();
							$(this).remove();
							$('#properties_wizard').click();
							return false;
						});
					}
					else
					if(data.product)
					{
						$('li#new_feature').remove();
						for(i=0; i<data.product.options.length; i++)
						{
							option_name = data.product.options[i].name;
							option_value = data.product.options[i].value;
							// Добавление нового свойства товара
							exists = false;

							if(!$('label.property:visible').filter(function(){ return $(this).text().toLowerCase() === option_name.toLowerCase();}).closest('li').find('input[name*="options"]').val(option_value).length)
							{
								f = $(new_feature).clone(true);
								f.find('input[name*="new_features_names"]').val(option_name);
								f.find('input[name*="new_features_values"]').val(option_value);
								f.appendTo('ul.new_features').fadeIn('slow').find('input[name*="new_feature_name"]');
							}
						}
					}
				},
				error: function(xhr, textStatus, errorThrown){
					alert("Error: " +textStatus);
				}
		});
		return false;
	});

	// Автозаполнение мета-тегов
	meta_title_touched = true;
	meta_keywords_touched = true;
	meta_description_touched = true;
	url_touched = true;

	if($('input[name="meta_title"]').val() == generate_meta_title() || $('input[name="meta_title"]').val() == '')
		meta_title_touched = false;
	if($('input[name="meta_keywords"]').val() == generate_meta_keywords() || $('input[name="meta_keywords"]').val() == '')
		meta_keywords_touched = false;
	if($('textarea[name="meta_description"]').val() == generate_meta_description() || $('textarea[name="meta_description"]').val() == '')
		meta_description_touched = false;
	if($('input[name="url"]').val() == generate_url() || $('input[name="url"]').val() == '')
		url_touched = false;

	$('input[name="meta_title"]').change(function() { meta_title_touched = true; });
	$('input[name="meta_keywords"]').change(function() { meta_keywords_touched = true; });
	$('textarea[name="meta_description"]').change(function() { meta_description_touched = true; });
	$('input[name="url"]').change(function() { url_touched = true; });

	$('input[name="name"]').keyup(function() { set_meta(); });
	$('select[name="brand_id"]').change(function() { set_meta(); });
	$('select[name="categories[]"]').change(function() { set_meta(); });

});

function set_meta() {
	if(!meta_title_touched)
		$('input[name="meta_title"]').val(generate_meta_title());
	if(!meta_keywords_touched)
		$('input[name="meta_keywords"]').val(generate_meta_keywords());
	if(!meta_description_touched)
		$('textarea[name="meta_description"]').val(generate_meta_description());
	if(!url_touched)
		$('input[name="url"]').val(generate_url());
}

function generate_meta_title() {
	name = $('input[name="name"]').val();
	return name;
}

function generate_meta_keywords() {
	name = $('input[name="name"]').val();
	result = name;
	brand = $('select[name="brand_id"] option:selected').attr('brand_name');
	if(typeof(brand) == 'string' && brand!='')
			result += ', '+brand;
	$('select[name="categories[]"]').each(function(index) {
		c = $(this).find('option:selected').attr('category_name');
		if(typeof(c) == 'string' && c != '')
			result += ', '+c;
	});
	return result;
}

function generate_meta_description() {
	if(typeof(tinyMCE.get('annotation')) =='object')
	{
		description = tinyMCE.get('annotation').getContent().replace(/(<([^>]+)>)/ig,'').replace(/(\&nbsp;)/ig,'').replace(/^\s+|\s+$/g,'').substr(0, 512);
		return description;
	}
	else
		return $('textarea[name="annotation"]').val().replace(/(<([^>]+)>)/ig,'').replace(/(\&nbsp;)/ig,'').replace(/^\s+|\s+$/g,'').substr(0, 512);
}

function generate_url() {
	url = $('input[name="name"]').val();
	url = url.replace(/[\s]+/gi, '-');
	url = translit(url);
	url = url.replace(/[^0-9a-z_\-]+/gi, '').toLowerCase();
	return url;
}

function translit(str) {
	var ru=("А-а-Б-б-В-в-Ґ-ґ-Г-г-Д-д-Е-е-Ё-ё-Є-є-Ж-ж-З-з-И-и-І-і-Ї-ї-Й-й-К-к-Л-л-М-м-Н-н-О-о-П-п-Р-р-С-с-Т-т-У-у-Ф-ф-Х-х-Ц-ц-Ч-ч-Ш-ш-Щ-щ-Ъ-ъ-Ы-ы-Ь-ь-Э-э-Ю-ю-Я-я").split("-")
	var en=("A-a-B-b-V-v-G-g-G-g-D-d-E-e-E-e-E-e-ZH-zh-Z-z-I-i-I-i-I-i-J-j-K-k-L-l-M-m-N-n-O-o-P-p-R-r-S-s-T-t-U-u-F-f-H-h-TS-ts-CH-ch-SH-sh-SCH-sch-'-'-Y-y-'-'-E-e-YU-yu-YA-ya").split("-")
	var res = '';
	for(var i=0, l=str.length; i<l; i++)
	{
		var s = str.charAt(i), n = ru.indexOf(s);
		if(n >= 0) { res += en[n]; }
		else { res += s; }
	}
	return res;
}
</script>
{/literal}