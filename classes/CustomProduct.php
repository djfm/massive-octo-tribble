<?php

class CustomProduct
{
	public static function findActiveByIdProduct($id_product)
	{
		$arr = Db::getInstance()->ExecuteS(
			'SELECT * FROM '._DB_PREFIX_.'fmdj_custompacks_product WHERE active=1 AND id_product='.(int)$id_product
		);
		if (count($arr) === 0)
			return false;
		else
			return $arr[0];
	}

	public static function findByIdProduct($id_product)
	{
		$arr = Db::getInstance()->ExecuteS(
			'SELECT * FROM '._DB_PREFIX_.'fmdj_custompacks_product WHERE id_product='.(int)$id_product
		);
		if (count($arr) === 0)
			return false;
		else
			return $arr[0];
	}

	public static function setIsCustomPack($id_product, $custom)
	{
		$cp = CustomProduct::findByIdProduct($id_product);
		if ($cp)
		{
			return Db::getInstance()->execute(
				'UPDATE '._DB_PREFIX_.'fmdj_custompacks_product SET active='.($custom ? 1 : 0).' WHERE id_product='.(int)$id_product
			);
		}
		else
		{
			return Db::getInstance()->execute(
				'INSERT INTO '._DB_PREFIX_.'fmdj_custompacks_product (id_product, active) VALUES ('.(int)$id_product.','.($custom ? 1 : 0).')'
			);
		}
	}

	public static function addOptGroup($id_product, $name)
	{
		$cp = CustomProduct::findActiveByIdProduct($id_product);
		if ($cp)
		{
			$n = (int)Db::getInstance()->getValue(
				'SELECT count(*) FROM '._DB_PREFIX_.'fmdj_custompacks_optgroup WHERE id_pack='.(int)$cp['id'].' AND optgroup=\''.pSQL($name).'\''
			);
			if($n === 0)
			{
				$p = 1+(int)Db::getInstance()->getValue(
					'SELECT MAX(position) FROM '._DB_PREFIX_.'fmdj_custompacks_optgroup WHERE id_pack='.(int)$cp['id']
				);
				$inserted = Db::getInstance()->execute(
					'INSERT INTO '._DB_PREFIX_.'fmdj_custompacks_optgroup (id_pack, optgroup, opttype, position) VALUES '
					.'('.(int)$cp['id'].',\''.pSQL($name).'\',\'unique\','.(int)$p.')'
				);

				if ($inserted)
					return true;
				else
					return "Could not create option group, don't know why.";
			}
			else
				return "An option group with this name already exists.";
		}
		else
			return "This product is not a custom pack.";
	}

	public static function getOptGroupId($id_product, $optgroup)
	{
		return (int)Db::getInstance()->getValue(
				 'SELECT o.id FROM '._DB_PREFIX_.'fmdj_custompacks_product p '
				.'INNER JOIN '._DB_PREFIX_.'fmdj_custompacks_optgroup o ON o.id_pack=p.id '
				.'WHERE p.id_product='.(int)$id_product.' AND o.optgroup = \''.pSQL($optgroup).'\' '
		);
	}

	public static function getComponents($id_product, $id_lang)
	{
		$sql = 'SELECT o.*, c.id_product as component_id_product, pl.name as product_name FROM '._DB_PREFIX_.'fmdj_custompacks_product p '
			 . 'INNER JOIN '._DB_PREFIX_.'fmdj_custompacks_optgroup o ON o.id_pack=p.id '
			 . 'LEFT JOIN '._DB_PREFIX_.'fmdj_custompacks_component c ON c.id_optgroup=o.id '
			 . 'LEFT JOIN '._DB_PREFIX_.'product_lang pl ON pl.id_product=c.id_product AND pl.id_lang='.(int)$id_lang.' '
			 . 'ORDER BY o.position, c.id';

		$rows = Db::getInstance()->ExecuteS($sql);

		$obj = array();

		foreach ($rows as $row) 
		{
			if (!isset($obj[$row['optgroup']]))
			{
				$obj[$row['optgroup']] = array(
					'optgroup' => $row['optgroup'],
					'opttype' => $row['opttype'],
					'products' => array()
				);
			}

			if($row['component_id_product'])
			{
				$obj[$row['optgroup']]['products'][$row['component_id_product']] = array(
					'name' => $row['product_name']
				);
			}
		}
		return $obj;
	}

	public static function addProduct($id_product, $optgroup, $id_product_to_add)
	{
		$id_optgroup = CustomProduct::getOptGroupId($id_product, $optgroup);
		if ($id_optgroup > 0)
		{
			if (Db::getInstance()->execute(
				 'INSERT IGNORE INTO '._DB_PREFIX_.'fmdj_custompacks_component (id_optgroup, id_product) VALUES '
				.'('.(int)$id_optgroup.','.(int)$id_product_to_add.')'
			))
				return true;
			else
				return "Could not add product to option group.";
		}
		else
			return "Could not find option group.";
	}

	public static function removeProduct($id_product, $optgroup, $id_product_to_remove)
	{
		$id_optgroup = CustomProduct::getOptGroupId($id_product, $optgroup);
		if ($id_optgroup > 0)
		{
			if (Db::getInstance()->execute(
				 'DELETE FROM '._DB_PREFIX_.'fmdj_custompacks_component '
				.'WHERE id_optgroup='.(int)$id_optgroup.' AND id_product='.(int)$id_product_to_remove
			))
				return true;
			else
				return "Could not remove product from option group.";
		}
		else
			return "Could not find option group.";
	}
}