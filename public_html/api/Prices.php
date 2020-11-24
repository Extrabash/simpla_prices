<?php

/**
 * Работа с вариантами товаров
 *
 * @copyright 	2011 Denis Pikusov
 * @link 		http://simplacms.ru
 * @author 		Denis Pikusov
 *
 */

require_once('Simpla.php');

class Prices extends Simpla
{
	/**
	* Функция возвращает цены вариантов
	* @param	$variant_id
	* @retval	array
	*/

	// Берем все вариации цен одного варианта товара
	public function get_variant_prices($variant_id)
	{

		if(empty($variant_id))
			return false;

		$query = $this->db->placehold("SELECT
			vp.id,
			vp.variant_id,
			vp.from_amount,
			vp.price,
			NULLIF(vp.compare_price, 0) as compare_price
			FROM __variant_prices AS vp
			WHERE
			1
			AND vp.variant_id = ?
			ORDER BY vp.from_amount", intval($variant_id));

		$this->db->query($query);
		return $this->db->results();
	}

	// Берем конкретные цены в зависимости от количества товара
	public function get_variant_price($variant_id, $amount)
	{
		if(empty($variant_id) || empty($amount))
			return false;

		$query = $this->db->placehold("SELECT
			vp.id,
			vp.variant_id,
			vp.from_amount,
			vp.price,
			NULLIF(vp.compare_price, 0) as compare_price
			FROM __variant_prices AS vp
			WHERE
			1
			AND vp.variant_id = ?
			AND vp.from_amount = (SELECT MAX(from_amount) FROM __variant_prices WHERE from_amount <= ? AND variant_id = ?)
			LIMIT 1", intval($variant_id), intval($amount), intval($variant_id));


		$this->db->query($query);

		$variant = $this->db->result();

		return $variant;
	}

	public function update_variant_price($id ,$price)
	{
		if($price->from_amount > 0 || empty($price->from_amount)) {
			$query = $this->db->placehold("UPDATE __variant_prices SET ?% WHERE id=? LIMIT 1", $price, intval($id));
			$this->db->query($query);
			return $id;
		}
		else
			return false;
	}

	public function add_variant_price($price)
	{
		if($price->from_amount > 0) {
			$query = $this->db->placehold("INSERT INTO __variant_prices SET ?%", $price);
			$this->db->query($query);
			return $this->db->insert_id();
		}
		else
			return false;
	}

	public function delete_variant_price($id)
	{
		if(!empty($id))
		{
			$query = $this->db->placehold("DELETE FROM __variant_prices WHERE id = ? LIMIT 1", intval($id));
			$this->db->query($query);
		}
	}

}
