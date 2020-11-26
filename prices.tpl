{foreach $product->variants as $v}
{if $v->prices}
{foreach $v->prices as $vp}
<div title="Актуальная цена" class="val product-price{if $product->variants|count>1}{if $smarty.get.variant == $v->id}{elseif $v@first and !$smarty.get.variant}{else} hide{/if}{/if}" id="product-price_{$v->id}">
    <nobr><span class="product-price-fig">{$vp->price|convert}</span> <span class="product-price-sign">{$currency->sign|escape}</span></nobr>
</div>
{if $vp->compare_price > 0}
<div title="Старая цена" class="old product-xprice{if $product->variants|count>1}{if $smarty.get.variant == $v->id}{elseif $v@first and !$smarty.get.variant}{else} hide{/if}{/if}" id="product-xprice_{$v->id}">
    <nobr><span class="product-xprice-fig">{$vp->compare_price|convert}</span> <span class="product-xprice-sign">{$currency->sign|escape}</span></nobr>
</div>
{/if}
{/foreach}
{/if}
{/foreach}
