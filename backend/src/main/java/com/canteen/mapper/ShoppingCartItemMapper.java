package com.canteen.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.canteen.entity.ShoppingCartItem;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ShoppingCartItemMapper extends BaseMapper<ShoppingCartItem> {
}
